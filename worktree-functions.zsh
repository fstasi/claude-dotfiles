#!/bin/zsh

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
gwt() {
    local cmd="${1:-}"

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

# Internal: fuzzy-pick a git worktree and cd into it
_gwt_list() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "✗ Error: fzf is required but not installed"
        echo "  Install with: brew install fzf"
        return 1
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ Error: Not in a git repository"
        return 1
    fi

    local dir
    dir=$(git worktree list --porcelain \
        | awk '/^worktree / { sub(/^worktree /, ""); print }' \
        | fzf --prompt="Git worktrees > ")

    if [ -n "$dir" ]; then
        builtin cd "$dir" || return
    fi
}

# Internal: create a worktree
_gwt_create() {
    local branch_prefix="${GWT_BRANCH_PREFIX:-}"
    local base_dir="${GWT_WORKTREE_DIR:-$HOME/worktrees}"

    if [ $# -eq 0 ]; then
        echo "Usage: gwt create|add <branch-name>"
        if [ -n "$branch_prefix" ]; then
            echo "Creates branch $branch_prefix/<branch-name> at $base_dir/\$REPO_NAME/$branch_prefix/<branch-name>"
        else
            echo "Creates branch <branch-name> at $base_dir/\$REPO_NAME/<branch-name>"
        fi
        return 1
    fi

    if [ -z "$branch_prefix" ]; then
        echo "⚠ Warning: GWT_BRANCH_PREFIX is not set, using branch name directly"
    fi

    echo "→ Checking git repository..."
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ Error: Not in a git repository"
        return 1
    fi
    echo "✓ Git repository verified"

    local branch_suffix="$1"
    local user_branch
    if [ -n "$branch_prefix" ]; then
        user_branch="$branch_prefix/$branch_suffix"
    else
        user_branch="$branch_suffix"
    fi

    # Validate branch name
    if ! git check-ref-format --branch "$user_branch" 2>/dev/null; then
        echo "✗ Error: Invalid branch name: $user_branch"
        return 1
    fi

    local repo_name="$(basename "$(git rev-parse --show-toplevel)")"
    if [ -z "$repo_name" ]; then
        echo "✗ Error: Could not determine repository name"
        return 1
    fi

    local worktree_path
    if [ -n "$branch_prefix" ]; then
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

    if [ -d "$worktree_path" ]; then
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

# Internal: interactively select and remove worktrees
_gwt_cleanup() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "✗ Error: fzf is required but not installed"
        echo "  Install with: brew install fzf"
        return 1
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ Error: Not in a git repository"
        return 1
    fi

    local repo_root="$(git rev-parse --show-toplevel)"

    # Let user select with fzf
    local selected
    selected=$(git worktree list --porcelain \
        | awk '/^worktree / { sub(/^worktree /, ""); print }' \
        | fzf -m --height=50% --prompt="Select worktrees to remove (Tab to select) > ")

    if [ -z "$selected" ]; then
        echo "No worktrees selected"
        return 0
    fi

    local had_errors=0
    while IFS= read -r worktree_path; do
        # Check if we're inside this worktree
        local current_dir="$(pwd)"
        if [[ "$current_dir/" == "$worktree_path/"* ]]; then
            echo "⚠ Warning: Currently inside worktree being removed"
            echo "→ Changing to repository root: $repo_root"
            builtin cd "$repo_root" || return 1
        fi

        echo "Removing worktree: $worktree_path"
        if ! git worktree remove "$worktree_path" --force 2>&1; then
            echo "  ⚠ Warning: Failed to remove worktree: $worktree_path"
            had_errors=1
        else
            echo "✓ Removed: $(basename "$worktree_path")"
        fi
    done <<< "$selected"

    if [ "$had_errors" -eq 1 ]; then
        echo ""
        echo "⚠ Some worktrees could not be removed"
        echo "  Run 'git worktree prune' after resolving issues"
        return 1
    fi

    echo ""
    echo "✓ Cleanup complete"
}
