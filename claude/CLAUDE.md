# Claude Code Configuration

User-defined skills take precedence over plugin-provided functionality.

## Available Skills

### Workflows

| Skill | Description |
|-------|-------------|
| `/user:workflow-jira` | Work on Jira issue: worktree → plan → implement → PR |
| `/user:workflow-create-pr` | Create PR with team conventions |
| `/user:workflow-monitor-ci` | Monitor CI and report failures (background agent) |

### Repository Rules

| Skill | Description |
|-------|-------------|
| `/user:repo-dd-source-rules` | dd-source build commands (bzl, proto, gazelle) |
| `/user:repo-dd-source-e2e` | dd-source E2E testing on staging (background agent) |
| `/user:repo-web-ui-rules` | web-ui conventions (preprod branch, static hash) |

### Always Active

| Skill | Description |
|-------|-------------|
| `git-rules` | Gitmoji format, atomic commits, rebase conventions |

## Naming Convention

- `workflow-*` - Multi-step workflows
- `repo-*` - Repository-specific rules
- `git-*` - Git conventions (always loaded)
