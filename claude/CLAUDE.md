# Claude Code Configuration

This directory contains skills and rules for working with this codebase.

## How Skills Work

- **Auto-triggered**: Loaded when patterns match your request or repository context
- **User-invocable**: Manually invoked with `/user:skill-name`
- **Always active**: Loaded automatically for every session

## Important: Collision Handling

**When plugins and user-defined skills or commands collide, always follow user-defined skills and commands.**

User-defined skills in this directory take precedence over any plugin-provided functionality. This ensures your custom workflows and conventions are always respected.

## Available Skills

### Workflows

**Main Workflow**
- `/user:workflow-jira` - Complete Jira workflow: worktree setup → plan → implement → commit → push → PR

**PR & CI**
- `/user:workflow-create-pr` - Create PR with team conventions and Jira linking
- `/user:workflow-monitor-ci` - Monitor CI jobs and fix failures

**Repository-Specific**
- `/user:repo-dd-source-rules` - Build commands for dd-source (bzl, proto, gazelle)
- `/user:repo-dd-source-e2e` - E2E testing on staging for dd-source

### Rules (Always Active)

- `git-rules` - Gitmoji commit format, rebase conventions

## Quick Reference

### Work on Jira Issue
```
work on SXS-1227
```
or
```
work on https://datadoghq.atlassian.net/browse/SXS-1227
```

### Create PR
```
create pr
```

### Monitor CI
```
monitor ci
```

### E2E Testing (dd-source)
```
e2e test
```
or
```
test on staging
```

## Naming Convention

Skills are organized with prefixes for clarity:
- `git-*` - Git conventions (always loaded)
- `workflow-*` - User-invocable workflows
- `repo-*` - Repository-specific rules/workflows
