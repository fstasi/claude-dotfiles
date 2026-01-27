#!/bin/zsh

# Unified git worktree command
# Usage:
#   gwt              - fuzzy select and cd into a worktree
#   gwt create <name> - create a new worktree with branch fstasi/<name>
#   gwt cleanup      - remove all temporary worktrees for current repo
gwt() {
    local cmd="${1:-}"

    case "$cmd" in
        create)
            shift
            _gwt_create "$@"
            ;;
        cleanup)
            shift
            _gwt_cleanup "$@"
            ;;
        "")
            _gwt_list
            ;;
        *)
            echo "Usage: gwt [command]"
            echo ""
            echo "Commands:"
            echo "  (no args)       Fuzzy select and cd into a worktree"
            echo "  create <name>   Create worktree with branch fstasi/<name>"
            echo "  cleanup         Remove all temporary worktrees for current repo"
            return 1
            ;;
    esac
}

# Internal: fuzzy-pick a git worktree and cd into it
_gwt_list() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ Error: Not in a git repository"
        return 1
    fi

    local dir
    dir=$(git worktree list --porcelain \
        | awk '/^worktree / { print $2 }' \
        | fzf --prompt="Git worktrees > ")

    if [ -n "$dir" ]; then
        cd "$dir" || return
    fi
}

# Internal: create a temporary worktree
_gwt_create() {
    local branch_prefix="fstasi"
    local base_dir="${DATADOG_ROOT}/tmp-worktrees"

    if [ $# -eq 0 ]; then
        echo "Usage: gwt create <branch-name>"
        echo "Creates branch $branch_prefix/<branch-name> at $base_dir/\$REPO_NAME/$branch_prefix/<branch-name>"
        return 1
    fi

    if [ -z "$DATADOG_ROOT" ]; then
        echo "✗ Error: DATADOG_ROOT environment variable is not set"
        return 1
    fi

    echo "→ Checking git repository..."
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ Error: Not in a git repository"
        return 1
    fi
    echo "✓ Git repository verified"

    local branch_suffix="$1"
    local user_branch="$branch_prefix/$branch_suffix"
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local worktree_path="$base_dir/$repo_name/$branch_prefix/$branch_suffix"

    echo ""
    echo "Configuration:"
    echo "  Repository:    $repo_name"
    echo "  Branch:        $user_branch"
    echo "  Worktree path: $worktree_path"
    echo ""

    echo "→ Creating worktree directory..."
    if ! mkdir -p "$worktree_path"; then
        echo "✗ Error: Failed to create directory: $worktree_path"
        return 1
    fi
    echo "✓ Directory created: $worktree_path"

    echo ""
    echo "→ Setting up git worktree..."

    if git worktree add "$worktree_path" "$user_branch" 2>/dev/null; then
        echo "✓ Created worktree using existing branch '$user_branch'"
    else
        echo "  Branch '$user_branch' not found, creating new branch..."
        if git worktree add -b "$user_branch" "$worktree_path"; then
            echo "✓ Created new branch '$user_branch' and worktree"
        else
            echo "✗ Error: Failed to create worktree"
            echo "→ Cleaning up directory..."
            rmdir "$worktree_path" 2>/dev/null
            return 1
        fi
    fi

    echo ""
    echo "→ Switching to worktree directory..."
    builtin cd "$worktree_path"
    echo "✓ Now in: $(pwd)"

    if [ "$repo_name" = "web-ui" ]; then
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

# Internal: clean up all temporary worktrees for the current repo
_gwt_cleanup() {
    local base_dir="${DATADOG_ROOT}/tmp-worktrees"

    if [ -z "$DATADOG_ROOT" ]; then
        echo "✗ Error: DATADOG_ROOT environment variable is not set"
        return 1
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ Error: Not in a git repository"
        return 1
    fi

    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local tmp_repo_path="$base_dir/$repo_name"

    if [ ! -d "$tmp_repo_path" ]; then
        echo "No temporary worktrees found for repo: $repo_name"
        return 0
    fi

    find "$tmp_repo_path" -name ".git" -type f 2>/dev/null | while read -r git_file; do
        local worktree_path=$(dirname "$git_file")
        echo "Removing worktree: $worktree_path"
        git worktree remove "$worktree_path" --force 2>/dev/null || true
    done

    rm -rf "$tmp_repo_path"
    echo "✓ Cleaned up all temporary worktrees for repo: $repo_name"
}
