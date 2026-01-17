## Available Skills

| Skill | Description |
|-------|-------------|
| `/user:git-rules` | Git conventions for commits and rebasing |
| `/user:work-jira` | Full Jira issue workflow (auto-triggered) |
| `/user:monitor-ci` | Monitor CI and fix failures (auto-triggered) |
| `/user:create-pr` | Create PR with team conventions (auto-triggered) |
| `/user:e2e-dd-source` | E2E testing for dd-source (auto-triggered) |

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
