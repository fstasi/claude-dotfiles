## Jira Issue Workflow

When the user asks to work on a Jira issue, immediately invoke `/work-jira <issue>` using the Skill tool.

**Detect this intent when the user's request:**
- Contains "work on" + a Jira/Atlassian URL (e.g., `https://datadoghq.atlassian.net/browse/SXS-1227`)
- Contains "work on" + a Jira issue ID pattern (uppercase letters + hyphen + numbers, e.g., `SXS-1227`, `PROJ-123`, `ABC-1`)
- Contains phrases like "work on jira", "work on jira issue", "work on ticket"
- Otherwise indicates intent to start working on a Jira ticket

**Action:** Extract the issue ID or full URL and invoke:
```
/work-jira <extracted-issue-id-or-url>
```

Do not ask for confirmation - invoke the command directly when the pattern is detected.

## Git Rules

See `/user:git-rules` for commit conventions and rebasing rules.

## Monitor PRs CI Output

See `/user:monitor-ci` for the full workflow.

## PR Workflow

See `/user:create-pr` for the full workflow (includes extra rules for web-ui repo).

## Rules for working in dd-source repo
The following rules apply to changes happening in the search-experience domain


When asked to work on a service (such as entity service, or logs service) you might want to consider changes to both the specific worker (such as entities-search-worker) and  search-router.

When updating the proto use this command to update the go files: bzl run //:snapshot -- domains/search_experiences/...

When updating imports you can use the following command to update bzl files: bzl run //:gazelle

Always update and run tests, when possible.
To run tests use the following command bzl test domains/search_experiences/...
