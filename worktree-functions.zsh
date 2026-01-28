#!/bin/zsh
emulate -L zsh

# Unified git worktree command
# Usage:
#   gwt                 - show usage
#   gwt list|ls         - fuzzy select and cd into a worktree
#   gwt create|add <name> - create a new worktree
#   gwt cleanup|remove   - interactively select and remove worktrees
#
# Environment variables:
#   GWT_WORKTREE_DIR   - base directory for worktrees (default: ~/worktrees)
#   GWT_BRANCH_PREFIX  - prefix for branch names (e.g., "username")

# Constants
_GWT_DETACHED="(detached)"
_GWT_PR_TIMEOUT=5

gwt() {
    local cmd="${1-}"

    case "$cmd" in
        list|ls)
            _gwt_list
            ;;
        create|add)
            shift
            _gwt_create "$@"
            ;;
        cleanup|remove)
            _gwt_cleanup
            ;;
        *)
            echo "Usage: gwt <command>"
            echo ""
            echo "Commands:"
            echo "  list, ls            Fuzzy select and cd into a worktree"
            echo "  create, add <name>  Create worktree with branch [GWT_BRANCH_PREFIX/]<name>"
            echo "  cleanup, remove     Interactively select and remove worktrees"
            return 1
            ;;
    esac
}

# Internal: check if in a git repository
_gwt_require_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ Error: Not in a git repository"
        return 1
    fi
}

# Internal: check required dependencies for list/cleanup commands
_gwt_check_deps() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "✗ Error: fzf is required but not installed"
        echo "  Install with: brew install fzf"
        return 1
    fi
    if ! command -v gh >/dev/null 2>&1; then
        echo "✗ Error: gh CLI is required but not installed"
        echo "  Install with: brew install gh"
        return 1
    fi
    return 0
}

# Internal: get fzf preview command (shared between list and cleanup)
_gwt_fzf_preview_cmd() {
    cat <<'EOF'
branch={2}
if [[ "$branch" != "(detached)" ]]; then
    gh pr view "$branch" --json state,title,url -q '"PR: " + .title + "\nState: " + .state + "\n" + .url' 2>/dev/null || echo "No PR for $branch"
else
    echo "Detached HEAD"
fi
EOF
}

# Internal: get PR status for a branch (with timeout)
# Returns: "✓ merged", "✗ closed", "◉ open", or empty string
_gwt_pr_status() {
    local branch="$1"
    [[ -z "$branch" ]] && return

    local pr_state
    if command -v timeout >/dev/null 2>&1; then
        pr_state=$(timeout "$_GWT_PR_TIMEOUT" gh pr view "$branch" --json state -q '.state' 2>/dev/null)
    else
        # macOS fallback: use perl for timeout
        pr_state=$(perl -e 'alarm shift; exec @ARGV' "$_GWT_PR_TIMEOUT" gh pr view "$branch" --json state -q '.state' 2>/dev/null)
    fi

    case "$pr_state" in
        MERGED) echo "✓ merged" ;;
        CLOSED) echo "✗ closed" ;;
        OPEN)   echo "◉ open" ;;
    esac
}

# Internal: build worktree list with PR status (parallel fetch)
# Output: path<TAB>branch<TAB>pr_status (one per line)
_gwt_build_list() {
    local tmpdir
    tmpdir=$(mktemp -d) || return 1

    # Ensure cleanup on exit/interrupt
    trap "rm -rf '$tmpdir'" EXIT INT TERM

    local -a worktree_paths
    local -a worktree_branches
    local -a pids
    local idx=0

    # Parse worktrees and spawn parallel PR status fetches
    while IFS=$'\t' read -r wt_path branch; do
        worktree_paths+=("$wt_path")
        worktree_branches+=("$branch")

        if [[ "$branch" != "$_GWT_DETACHED" ]]; then
            ( _gwt_pr_status "$branch" > "$tmpdir/pr_$idx" 2>/dev/null ) &
            pids+=("$idx:$!")
        fi
        ((idx++))
    done < <(git worktree list --porcelain | awk -v detached="$_GWT_DETACHED" '
        /^worktree / { path=$0; sub(/^worktree /, "", path) }
        /^branch /   { branch=$0; sub(/^branch refs\/heads\//, "", branch); print path "\t" branch }
        /^detached$/ { print path "\t" detached }
    ')

    # Wait for all background jobs
    for entry in "${pids[@]}"; do
        local pid="${entry#*:}"
        wait "$pid" 2>/dev/null
    done

    # Output with statuses
    for ((i = 0; i < ${#worktree_paths[@]}; i++)); do
        local wt_path="${worktree_paths[$((i+1))]}"
        local branch="${worktree_branches[$((i+1))]}"
        local pr_status=""

        if [[ -f "$tmpdir/pr_$i" ]]; then
            pr_status=$(<"$tmpdir/pr_$i")
        fi
        printf "%s\t%s\t%s\n" "$wt_path" "$branch" "$pr_status"
    done

    # Cleanup handled by trap
}

# Internal: fuzzy-pick a git worktree and cd into it
_gwt_list() {
    _gwt_check_deps || return 1
    _gwt_require_git_repo || return 1

    local preview_cmd
    preview_cmd=$(_gwt_fzf_preview_cmd)

    local dir
    dir=$(_gwt_build_list \
        | fzf --prompt="Git worktrees > " \
              --delimiter=$'\t' \
              --with-nth=1,3 \
              --preview="$preview_cmd" \
              --preview-window=up:3:wrap \
        | cut -f1)

    if [[ -n "$dir" ]]; then
        builtin cd "$dir" || return
    fi
}

# Internal: create a worktree
_gwt_create() {
    local branch_prefix="${GWT_BRANCH_PREFIX:-}"
    local base_dir="${GWT_WORKTREE_DIR:-$HOME/worktrees}"

    if [[ $# -eq 0 ]]; then
        echo "Usage: gwt create|add <branch-name>"
        if [[ -n "$branch_prefix" ]]; then
            echo "Creates branch $branch_prefix/<branch-name> at $base_dir/\$REPO_NAME/$branch_prefix/<branch-name>"
        else
            echo "Creates branch <branch-name> at $base_dir/\$REPO_NAME/<branch-name>"
        fi
        return 1
    fi

    if [[ -z "$branch_prefix" ]]; then
        echo "⚠ Warning: GWT_BRANCH_PREFIX is not set, using branch name directly"
    fi

    echo "→ Checking git repository..."
    _gwt_require_git_repo || return 1
    echo "✓ Git repository verified"

    local branch_suffix="$1"
    local user_branch
    if [[ -n "$branch_prefix" ]]; then
        user_branch="$branch_prefix/$branch_suffix"
    else
        user_branch="$branch_suffix"
    fi

    # Validate branch name
    if ! git check-ref-format --branch "$user_branch" 2>/dev/null; then
        echo "✗ Error: Invalid branch name: $user_branch"
        return 1
    fi

    # Get repo name safely
    local toplevel
    toplevel="$(git rev-parse --show-toplevel)" || {
        echo "✗ Error: Could not determine repository root"
        return 1
    }
    local repo_name="$(basename "$toplevel")"

    local worktree_path
    if [[ -n "$branch_prefix" ]]; then
        worktree_path="$base_dir/$repo_name/$branch_prefix/$branch_suffix"
    else
        worktree_path="$base_dir/$repo_name/$branch_suffix"
    fi

    echo ""
    echo "Configuration:"
    echo "  Repository:    $repo_name"
    echo "  Branch:        $user_branch"
    echo "  Worktree path: $worktree_path"
    echo ""

    # Validate parent directory is writable
    local parent_dir="$(dirname "$worktree_path")"
    if ! mkdir -p "$parent_dir" 2>/dev/null; then
        echo "✗ Error: Cannot create worktree parent directory: $parent_dir"
        return 1
    fi

    if [[ -d "$worktree_path" ]]; then
        echo "✗ Error: Worktree path already exists: $worktree_path"
        return 1
    fi

    echo "→ Setting up git worktree..."

    if git show-ref --verify --quiet "refs/heads/$user_branch"; then
        if ! git worktree add "$worktree_path" "$user_branch"; then
            echo "✗ Error: Failed to create worktree from existing branch"
            return 1
        fi
        echo "✓ Created worktree using existing branch '$user_branch'"
    else
        echo "  Branch '$user_branch' not found, creating new branch..."
        if ! git worktree add -b "$user_branch" "$worktree_path"; then
            echo "✗ Error: Failed to create worktree"
            return 1
        fi
        echo "✓ Created new branch '$user_branch' and worktree"
    fi

    echo ""
    echo "→ Switching to worktree directory..."
    builtin cd "$worktree_path" || return 1
    echo "✓ Now in: $(pwd)"

    if [[ "$repo_name" = "web-ui" ]]; then
        echo ""
        echo "→ Detected web-ui repo, installing dependencies..."
        if command -v yarn >/dev/null 2>&1; then
            yarn
            echo "✓ Dependencies installed"
        else
            echo "⚠ Warning: yarn not found on PATH; skipping install"
        fi
    fi

    echo ""
    echo "✓ Worktree ready at: $worktree_path"
}

# Internal: resolve path handling symlinks
_gwt_resolve_path() {
    (cd -P "$1" 2>/dev/null && pwd)
}

# Internal: check if worktree has uncommitted changes
_gwt_is_dirty() {
    local wt_path="$1"
    # Check for uncommitted changes in the worktree
    git -C "$wt_path" status --porcelain 2>/dev/null | grep -q .
}

# Internal: interactively select and remove worktrees
_gwt_cleanup() {
    _gwt_check_deps || return 1
    _gwt_require_git_repo || return 1

    local repo_root
    repo_root="$(git rev-parse --show-toplevel)" || return 1

    local preview_cmd
    preview_cmd=$(_gwt_fzf_preview_cmd)

    # Let user select with fzf
    local selected
    selected=$(_gwt_build_list \
        | fzf -m \
              --height=50% \
              --prompt="Select worktrees to remove (Tab to select) > " \
              --delimiter=$'\t' \
              --with-nth=1,3 \
              --preview="$preview_cmd" \
              --preview-window=up:3:wrap)

    if [[ -z "$selected" ]]; then
        echo "No worktrees selected"
        return 0
    fi

    local had_errors=0
    local -a branches_to_delete

    while IFS=$'\t' read -r worktree_path branch pr_status; do
        # Resolve symlinks for accurate comparison
        local resolved_current
        resolved_current=$(_gwt_resolve_path "$(pwd)")
        local resolved_worktree
        resolved_worktree=$(_gwt_resolve_path "$worktree_path")

        # Check if we're inside this worktree
        if [[ -n "$resolved_current" && -n "$resolved_worktree" && "$resolved_current/" == "$resolved_worktree/"* ]]; then
            echo "⚠ Warning: Currently inside worktree being removed"
            echo "→ Changing to repository root: $repo_root"
            builtin cd "$repo_root" || return 1
        fi

        # Check for uncommitted changes
        if _gwt_is_dirty "$worktree_path"; then
            echo ""
            echo "⚠ Worktree has uncommitted changes: $worktree_path"
            echo -n "  Remove anyway? (y/N): "
            read -r confirm
            if [[ "$confirm" != [yY] ]]; then
                echo "  Skipping: $worktree_path"
                continue
            fi
        fi

        echo "Removing worktree: $worktree_path"
        if ! git worktree remove "$worktree_path" --force 2>&1; then
            echo "  ⚠ Warning: Failed to remove worktree: $worktree_path"
            had_errors=1
        else
            echo "✓ Removed: $(basename "$worktree_path")"

            # Track branch for potential deletion (skip detached and main branches)
            if [[ "$branch" != "$_GWT_DETACHED" && "$branch" != "main" && "$branch" != "master" ]]; then
                branches_to_delete+=("$branch")
            fi
        fi
    done <<< "$selected"

    # Offer to delete branches
    if [[ ${#branches_to_delete[@]} -gt 0 ]]; then
        echo ""
        echo "The following branches can be deleted:"
        for branch in "${branches_to_delete[@]}"; do
            echo "  - $branch"
        done
        echo -n "Delete these branches? (y/N): "
        read -r confirm
        if [[ "$confirm" == [yY] ]]; then
            for branch in "${branches_to_delete[@]}"; do
                if git branch -d "$branch" 2>/dev/null; then
                    echo "✓ Deleted branch: $branch"
                elif git branch -D "$branch" 2>/dev/null; then
                    echo "✓ Force deleted branch: $branch (had unmerged changes)"
                else
                    echo "⚠ Could not delete branch: $branch"
                fi
            done
        fi
    fi

    if [[ "$had_errors" -eq 1 ]]; then
        echo ""
        echo "⚠ Some worktrees could not be removed"
        echo "  Run 'git worktree prune' after resolving issues"
        return 1
    fi

    echo ""
    echo "✓ Cleanup complete"
}
