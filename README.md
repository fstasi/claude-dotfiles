# Claude Dotfiles

Personal [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration.

## Structure

```
├── CLAUDE.md          # Global instructions
├── settings.json      # Settings and permissions
└── skills/            # Custom workflows
```

## Installation

```bash
git clone git@github.com:fstasi/claude-dotfiles.git
cd claude-dotfiles

ln -sf "$(pwd)/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$(pwd)/settings.json" ~/.claude/settings.json
ln -sf "$(pwd)/skills" ~/.claude/skills
```

## Files

- **[CLAUDE.md](CLAUDE.md)** — Global behavior instructions
- **[skills/](skills/)** — Custom workflows (`/workflow-jira`, `/workflow-create-pr`, etc.)
