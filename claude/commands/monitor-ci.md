---
description: Monitor CI jobs for a PR and fix errors automatically
---

## Monitor PRs CI Output

After a PR is created or updated, follow this workflow:

### 1. Start Monitoring

Spawn an async subagent to monitor CI jobs for errors.

### 2. Fetch CI Status

Start an async subagent using `dd:fetch-ci-results` skill to check CI status:
- Poll periodically until jobs complete
- Identify any failing jobs or tests
- report back to the main agent

### 3. Handle Failures

In case of CI errors:
1. Analyze the failure logs
2. Perform fixes in the main agent using the `dd:ci:fix` skill
3. Commit and push the fixes
4. Restart monitoring to verify the fixes resolved the issue

### 4. Success Criteria

Monitoring is complete when:
- All CI jobs pass, OR
- User explicitly stops monitoring
