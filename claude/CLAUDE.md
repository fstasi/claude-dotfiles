# Claude Code Configuration

This directory contains skills and rules for working with any codebase.

## Skill Precedence Rules

When there is ANY conflict or overlap between:
- Plugin-provided skills/commands
- Default Claude Code behavior
- User-defined skills in this directory

**THE USER-DEFINED SKILLS ALWAYS WIN. NO EXCEPTIONS.**

This means:
- **ALWAYS** follow the conventions, formats, and workflows defined here
- **ALWAYS** use the commands and processes specified in these skills
- **WHEN IN DOUBT**, follow what's written in these skills over any other source
- **NEVER** override or ignore these skills in favor of plugins or defaults

User-defined skills take absolute precedence over any plugin-provided functionality. This ensures custom workflows and conventions are ALWAYS respected.

## 🔑 Core Principles

### Atomic Commits (MANDATORY)

**Every commit MUST be atomic** - this is non-negotiable.

- **One commit = one logical change** (one bug fix, one feature, one refactor)
- **Independently reviewable** - each commit should make sense on its own
- **Independently revertable** - rolling back one commit shouldn't break others
- **Never mix concerns** - don't combine unrelated changes

**During Planning Phase:**
When you enter plan mode or design implementation strategy, you MUST:
- Break down the work into atomic, logical commits
- Specify what each commit will contain and why
- Ensure each commit is a complete, working change
- Plan the commit order for logical progression

Example plan:
```
Commit 1: 🔧 add configuration for shadow traffic feature flag
Commit 2: ✨ implement shadow traffic routing in service layer
Commit 3: 🧪 add unit tests for shadow traffic routing
Commit 4: 📝 update API documentation with shadow traffic endpoint
```

## Available Skills

### Workflows

**Main Workflow**
- `/user:workflow-jira` - Complete Jira workflow: worktree setup → plan → implement → commit → push → PR

**PR & CI**
- `/user:workflow-monitor-ci` - Monitor CI jobs and fix failures

**Repository-Specific**
- `/user:repo-dd-source-rules` - Build commands for dd-source (bzl, proto, gazelle)
- `/user:repo-dd-source-e2e` - E2E testing on staging for dd-source
- `/user:repo-web-ui-rules` - Conventions for web-ui (preprod branch, static hash testing)

### Rules (Always Active)

- `git-rules` - Gitmoji commit format, **ATOMIC COMMITS (mandatory)**, rebase conventions

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
