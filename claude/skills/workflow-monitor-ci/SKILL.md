---
name: workflow-monitor-ci
description: Monitor CI jobs for a PR and report failures
context: fork
agent: general-purpose
---

## Monitor CI Workflow

### 1. Get PR Information


### 2. Monitor CI Status

Poll CI status using GitHub CLI

Poll every 30 seconds until all jobs complete.

### 3. Handle Failures

Report to main agent:
- Which jobs failed
- Error messages
- Suggested fixes if obvious
- Ask user if you can't fix it easily yourself 

### 4. Report Success

When all CI jobs pass:
```
"✅ All CI checks have passed for PR #<number>!"
```

### 5. Edge Cases

- **Cancelled**: Report and ask if monitoring should continue
- **Timeout (>30 min)**: Report current status
- **Pending checks**: Report which are still pending
