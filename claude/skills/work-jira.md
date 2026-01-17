---
description: Work on a Jira issue - setup worktree, plan, implement, commit, push, and create PR
priority: 1
user-invocable: true
allowed-tools: Bash(tmp-worktree:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(gh pr create:*), mcp__plugin_atlassian-remote-mcp_atlassian-remote__getJiraIssue, mcp__atlassian-remote__getJiraIssue
trigger:
  - pattern: "work on .*(jira|ticket|issue|SXS-|PROJ-|datadoghq.atlassian.net)"
    description: Automatically invoked when user wants to work on a Jira issue
---

## Input

The user provided: $ARGUMENTS

## Step 1: Extract Issue ID

Parse the input to extract the Jira issue ID:
- From URL `https://datadoghq.atlassian.net/browse/SXS-1227` → extract `SXS-1227`
- From issue ID `SXS-1227` → use directly
- Pattern: uppercase letters + hyphen + numbers (e.g., `SXS-1227`, `PROJ-123`)

## Step 2: Set Up Worktree

Run the worktree setup:
```bash
tmp-worktree <issue-id>
```

Wait for completion and note the new worktree directory path.

**Ask user**: Do you want to rebase on the base branch?
- For **web-ui** repo: rebase on `preprod`
- For other repos: rebase on `main`

## Step 3: Fetch Jira Ticket Details

Use the Atlassian MCP tool with:
- **cloudId**: `datadoghq.atlassian.net`
- **issueIdOrKey**: the extracted issue ID

Extract:
- Summary (title)
- Description
- Acceptance criteria
- Implementation instructions (commit format, PR requirements, testing needs)

## Step 4: Plan the Changes

Enter **plan mode** to:
1. Analyze ticket requirements against the codebase
2. Explore relevant code areas
3. Design the implementation approach
4. Present a clear, actionable plan

**Important**: Note any ticket-specific instructions about commits, PR format, or testing.

## Step 5: Implement (After User Approval)

Once approved:
1. Implement all planned changes
2. Run relevant tests
3. Follow project conventions from `/user:git-rules`

## Step 6: Commit, Push, and Create PR

1. **Commit**: Use gitmoji format per `/user:git-rules`
2. **Push**: Push branch to remote
3. **Create PR**: Follow `/user:create-pr` conventions

## Step 7: Monitor CI

After PR creation:
1. Spawn async subagent to monitor CI and fix issues using `/user:monitor-ci` skill
2. Push fixes and re-monitor until CI passes

Return the PR URL when complete.
