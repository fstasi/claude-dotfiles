---
name: workflow-monitor-ci
description: Monitor CI jobs for a PR and fix failures (runs as background agent)
---

## ⚠️ IMPORTANT: This Workflow Runs as a Background Agent

**This skill describes a workflow that should be executed by a background agent**, not the main conversation agent. This keeps the main context clean and lean.

### How the Main Agent Should Invoke This

When CI monitoring is needed, the main agent should:

1. **Spawn a background agent** using the Task tool:
   ```
   Task tool with:
   - subagent_type: "general-purpose"
   - run_in_background: true
   - prompt: "Monitor CI for PR <PR-URL-or-number>. Follow the workflow-monitor-ci skill. Report back when all checks pass or if any failures occur that need attention."
   ```

2. **Inform the user**:
   ```
   "I've spawned a background agent to monitor CI for your PR. It will report back when all checks pass or if any failures occur. You can continue working on other tasks in the meantime."
   ```

3. **Continue with other work** - don't block waiting for CI

---

## Monitor CI Workflow (For Background Agent)

This section is executed by the background agent.

### 1. Get PR Information

Identify the PR to monitor:
```bash
gh pr view  # Current branch PR
gh pr view <number>  # Specific PR
```

### 2. Monitor CI Status

Poll CI status periodically using GitHub CLI:
```bash
gh pr checks
```

Look for:
- ✅ Passing jobs
- ❌ Failing jobs
- ⏳ In-progress jobs

**Polling strategy:**
- Check every 30 seconds while jobs are running
- Continue monitoring until all jobs complete (pass or fail)

### 3. Handle Failures

When CI fails:

**Analyze**: Get failure details:
```bash
gh pr checks --watch  # Live monitoring
gh run view <run-id>  # Detailed logs
```

**Report to main agent**: If failures occur, report:
- Which jobs failed
- Error messages and logs
- Suggested fixes if obvious

**Do NOT fix automatically** - report findings and wait for main agent/user decision.

### 4. Report Success

When all CI jobs pass:

Report to the main conversation:
```
"✅ All CI checks have passed for PR #<number>!"
```

### 5. Handle Edge Cases

- **Cancelled jobs**: Report and ask if monitoring should continue
- **Timeout**: If CI takes longer than expected (>30 min), report status
- **Pending required checks**: Report which checks are still pending
