---
name: workflow-create-pr
description: Create a PR following team conventions
---

## Create PR Workflow

### 1. PR Title Format

- **Format**: `[<jira-issue-number>] <jira issue title>`
- **Example**: `[SXS-1227] Add shadow traffic support for metrics endpoint`
- Use the original Jira issue title unless it doesn't represent the changes well
- Always include `[<jira-issue-number>]` at the beginning of the title

### 2. PR Description

Check for repo template at `.github/PULL_REQUEST_TEMPLATE.md` and follow it.

Otherwise, include:
- Motivation (include Link to Jira ticket)
- QA section (Testing instructions if applicable)
- Blast Radius

### 3. Create the Draft PR

**Always create PRs as drafts** using `gh pr create --draft`.

### 4. Return PR URL

Display the PR URL to the user when complete.

### 5. Monitor CI and fix issues

After creating the PR, spawn a background agent to monitor CI and fix any failures:

```
Use Task tool with: /user:workflow-monitor-ci
```

### 6. Notify User

Once CI passes, provide the user the PR URL and inform that:
- The PR is ready for their review (keep it as draft)
- Ask if they want any changes before marking it ready for review
