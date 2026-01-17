---
name: workflow-monitor-ci
description: Monitor CI jobs for a PR and report failures. Run this workflow every time new commits are pushed to a remote branch.
context: fork
agent: general-purpose
---

## Monitor PRs CI Output

Important: run this workflow in an async subagent, to keep the main agent context as clear and lean as possible.
This workflow reports back to the main agent when jobs fails or when all pass.

### 1. Fetch CI Status

Start an async subagent using `dd:fetch-ci-results` skill to check CI status:
- Poll periodically until jobs complete
- Identify any failing jobs or tests
- report back to the main agent

### 2. Handle Failures

In case of CI errors:
1. Analyze the failure logs
2. Perform fixes in the main agent using the `dd:ci:fix` command
3. Commit and push the fixes
4. Restart monitoring to verify the fixes resolved the issue

### 3. Success Criteria

Monitoring is complete when:
- All CI jobs pass, OR
- User explicitly stops monitoring
