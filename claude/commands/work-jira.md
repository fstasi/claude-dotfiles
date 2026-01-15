---
allowed-tools: Bash(tmp-worktree:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(gh pr create:*), mcp__plugin_atlassian-remote-mcp_atlassian-remote__getJiraIssue
description: Work on a Jira issue - setup worktree, plan, implement, commit, push, and create PR
---

## Input

The user provided: $ARGUMENTS

## Step 1: Extract Issue ID

Parse the input to extract the Jira issue ID:
- If given a URL like `https://datadoghq.atlassian.net/browse/SXS-1227`, extract `SXS-1227`
- If given just an issue ID like `SXS-1227`, use it directly

## Step 2: Set Up Worktree

Run the worktree setup script:
```
tmp-worktree <issue-id>
```

Wait for completion and note the new worktree directory path from the output.

Prompt the user if they want to rebase on the base branch (preprod if the repo is web-ui, main otherwise).
If the user want to rebase, do it.

## Step 3: Fetch Jira Ticket Details

Use `mcp__plugin_atlassian-remote-mcp_atlassian-remote__getJiraIssue` with:
- cloudId: `datadoghq.atlassian.net`
- issueIdOrKey: the extracted issue ID

Extract from the ticket:
- Summary
- Description
- Acceptance criteria
- Any specific implementation instructions (commit format, PR requirements, etc.)

## Step 4: Plan the Changes

Enter plan mode to:
1. Analyze the ticket requirements
2. Explore the codebase to understand relevant areas
3. Design the implementation approach
4. Present a clear plan to the user

**Important**: Note any specific instructions from the ticket about commit messages, PR format, or testing.

## Step 5: Implement (After User Approval)

Once the user approves the plan:
1. Implement all planned changes
2. Run relevant tests
3. Follow project conventions

## Step 6: Commit, Push, and Create PR

After implementation:

1. **Commit**: Follow `/user:git-rules` conventions (gitmoji, short messages).
2. **Push**: Push branch to remote
3. **Create PR**: Follow the rules in `/user:create-pr`:

## Step 7: Monitor CI

After the PR is created, follow `/user:monitor-ci`:
- Spawn async subagent to monitor CI jobs
- Fix any failures using `dd:ci:fix` skill
- Push fixes and re-monitor until CI passes

Return the PR URL to the user when complete.
