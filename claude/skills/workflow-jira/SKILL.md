---
name: workflow-jira
description: Work on a Jira issue - setup worktree, plan, implement, commit, push, and create PR
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
- Check repository-specific skills (e.g., repo-web-ui-rules, repo-dd-source-rules) for the correct base branch
- Default: rebase on `main`

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
4. **Break down into ATOMIC COMMITS** - plan each logical change as a separate commit
5. Present a clear, actionable plan with commit-by-commit breakdown

**Important**:
- MANDATORY: Plan must include atomic commit breakdown (one logical change per commit)
- Note any ticket-specific instructions about commits, PR format, or testing

## Step 5: Implement (After User Approval)

Once approved:
1. Implement all planned changes
2. Run relevant tests
3. Follow git conventions (gitmoji format, concise messages)

## Step 6: Commit and Push

**CRITICAL: Follow the atomic commit plan from Step 4**

1. **Review changes**: Run `git status` and `git diff`
2. **Commit atomically**: Create separate commits for each logical change as planned
   - Use gitmoji format (e.g., `✨ add feature`, `🐛 fix bug`)
   - Each commit should be independently reviewable and revertable
   - Never mix unrelated changes in a single commit
3. **Push**: Push branch to remote with `git push -u origin <branch-name>`

## Step 7: Create PR

Create a **draft PR** following team conventions:
- **Title format**: `[<jira-issue-number>] <jira issue title>`
- **Description**: Include summary, Jira link, and note about Claude-generated implementation
- Use `gh pr create --draft` with proper formatting
- Repository-specific rules (e.g., static hash for web-ui) will be applied automatically

## Step 8: CI Monitoring

After PR creation, CI checks will run automatically. Monitor and fix any failures as needed.

Return the PR URL when complete.
