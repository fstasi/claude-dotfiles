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

### Background Agents for CI and Testing (MANDATORY)

**CI monitoring and testing jobs MUST run in background agents** - this keeps the main context clean and lean.

**When to Use Background Agents:**
- **CI Monitoring** - After creating a PR, spawn a background agent to monitor CI
- **E2E Testing** - When running E2E tests, spawn a background agent
- **Long-running tests** - Any test suite that takes more than a few seconds

**How to Spawn Background Agents:**

Use the Task tool with `run_in_background: true`:

```
Task tool with:
- subagent_type: "general-purpose" (or appropriate type)
- run_in_background: true
- prompt: "Monitor CI for PR #123 and report back when done or if failures occur"
```

**Background Agent Behavior:**
- Agent runs independently and doesn't block the main conversation
- Returns an `output_file` path for monitoring progress
- Main agent can check progress by reading the output file
- Background agent reports back when:
  - ✅ Task completes successfully
  - ❌ Error or failure occurs
  - ⏱️ User needs to be notified of status

**Main Agent Responsibilities:**
- Tell the user a background agent has been spawned
- Provide the output file path if user wants to monitor
- Continue with other work while background agent runs
- Check back on background agent periodically if needed

Example:
```
"I've spawned a background agent to monitor CI for your PR. It will report back when all checks pass or if any failures occur. You can continue working on other tasks in the meantime."
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
- `/user:workflow-create-pr` - Create PR with team conventions and Jira linking

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
