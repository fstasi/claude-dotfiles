## Jira Issue Workflow

When the user asks to work on a Jira issue, immediately invoke `/work-jira <issue>` using the Skill tool.

**Detect this intent when:**
- Contains "work on" + a Jira/Atlassian URL (e.g., `https://datadoghq.atlassian.net/browse/SXS-1227`)
- Contains "work on" + a Jira issue ID (e.g., `SXS-1227`, `PROJ-123`, `ABC-1`)
- Contains phrases like "work on jira", "work on ticket", "start on issue"

**Action:** Extract the issue ID or URL and invoke `/work-jira <issue>` directly.

## Available Skills

| Skill | Description |
|-------|-------------|
| `/user:git-rules` | Git conventions for commits and rebasing |
| `/user:work-jira` | Full Jira issue workflow |
| `/user:monitor-ci` | Monitor CI and fix failures |
| `/user:create-pr` | Create PR with team conventions |
| `/user:e2e-dd-source` | E2E testing for dd-source |

## Git Rules

See `/user:git-rules` for commit conventions and rebasing rules.

## CI Monitoring

See `/user:monitor-ci` for the CI monitoring and auto-fix workflow.

## PR Creation

See `/user:create-pr` for the full workflow (includes extra rules for web-ui and dd-source repos).

## dd-source Repository Rules

These rules apply to changes in the search-experience domain:

### Service Changes
When working on a service (entity service, logs service, etc.), consider changes to both:
- The specific worker (e.g., `entities-search-worker`)
- The `search-router`

### Proto Updates
After updating proto files, regenerate Go code:
```bash
bzl run //:snapshot -- domains/search_experiences/...
```

### Import Updates
After updating imports, regenerate bzl files:
```bash
bzl run //:gazelle
```

### Testing
Always run tests when possible:
```bash
bzl test domains/search_experiences/...
```
