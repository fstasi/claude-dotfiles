---
name: workflow-jira
description: Work on a Jira issue - setup worktree, plan, implement, commit, push, and create PR
---

## Input

The user provided: $ARGUMENTS

## Step 1: Extract Issue ID

Parse input to extract Jira issue ID:
- URL `https://datadoghq.atlassian.net/browse/SXS-1227` → `SXS-1227`
- Direct ID `SXS-1227` → use as-is

## Step 2: Set Up Worktree

```bash
tmp-worktree <issue-id>
```

**Ask user**: Rebase on base branch?
- Check repo-specific skills for correct base branch
- Default: `main`

## Step 3: Fetch Jira Ticket

Use Atlassian MCP tool:
- **cloudId**: `datadoghq.atlassian.net`
- **issueIdOrKey**: extracted issue ID

Extract: summary, description, acceptance criteria, implementation instructions.

## Step 4: Plan Changes

Enter **plan mode**:
1. Analyze requirements against codebase
2. Design implementation
3. **Break into atomic commits** (one logical change per commit)
4. Present commit-by-commit breakdown

## Step 5: Implement

After approval:
1. Implement changes
2. Run tests
3. Follow git-rules (gitmoji, atomic commits)

## Step 6: Commit and Push

1. `git status` and `git diff` to review
2. Commit atomically per plan
3. `git push -u origin <branch>`

## Step 7: Create PR

Create **draft PR**:
- Title: `[<jira-id>] <jira title>`
- Use `gh pr create --draft`

## Step 8: Monitor CI

Spawn background agent for CI monitoring:
```
Task tool: subagent_type="general-purpose", run_in_background=true
Prompt: "Monitor CI for PR <URL>. Follow workflow-monitor-ci skill."
```

Return PR URL to user.
