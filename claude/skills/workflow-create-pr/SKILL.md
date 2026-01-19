---
name: workflow-create-pr
description: Create a PR following team conventions
---

## Create PR Workflow

### 1. PR Title Format

- **Format**: `[<jira-issue-number>] <jira issue title>`
- **Example**: `[SXS-1227] Add shadow traffic support for metrics endpoint`
- Use the original Jira issue title unless it doesn't represent the changes well
- Always include `[<jira-issue-number>]` at the beginning

### 2. PR Description

Check for repo template at `.github/PULL_REQUEST_TEMPLATE.md` and follow it.

Otherwise, include:
- Motivation (include Link to Jira ticket)
- QA section (Testing instructions if applicable)
- Blast Radius

### 3. Create the Draft PR

**Always create PRs as drafts** using the `--draft` flag.

Use `gh pr create` with heredoc for clean formatting:

```bash
gh pr create --draft --title "PR title here" --body "$(cat <<'EOF'
<PR description, as described above>
EOF
)"
```

### 4. Return PR URL

Display the PR URL to the user when complete.

### 5. Monitor CI

After PR is created, start CI monitoring using `workflow-monitor-ci`.
