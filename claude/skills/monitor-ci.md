---
description: Monitor CI jobs for a PR and automatically fix failures
priority: 1
user-invocable: true
trigger:
  - pattern: "monitor.*(ci|pipeline|build|checks)"
    description: Automatically invoked when user wants to monitor CI
  - pattern: "check.*(ci|pipeline|build|status)"
    description: Invoked when checking CI status
---

## Monitor CI Workflow

### 1. Start Async Monitoring

Spawn an **async subagent** to monitor CI jobs. This allows the main conversation to continue while CI runs.

### 2. Fetch CI Status

Use the `dd:fetch-ci-results` skill to:
- Poll CI status periodically
- Identify failing jobs or tests
- Collect error logs from failures
- Report status back to main agent

### 3. Handle Failures

When CI fails:

1. **Analyze**: Review failure logs to understand the root cause
2. **Fix**: Use `dd:ci:fix` skill to implement fixes in the main agent
3. **Commit & Push**: follow /user:git-rules commit conventions
4. **Re-monitor**: Restart monitoring to verify fixes

### 4. Success Criteria

Monitoring is complete when:
- All CI jobs pass ✅
- User explicitly stops monitoring 🛑

### 5. Reporting

Provide clear status updates:
- "CI running: 3/5 jobs complete"
- "CI failed: TypeScript errors in `src/components/Button.tsx`"
- "CI passed: All checks green"
