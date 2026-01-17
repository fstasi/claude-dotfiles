---
name: workflow-monitor-ci
description: Monitor CI jobs for a PR and fix failures
---

## Monitor CI Workflow

### 1. Get PR Information

Identify the PR to monitor:
```bash
gh pr view  # Current branch PR
gh pr view <number>  # Specific PR
```

### 2. Check CI Status

Poll CI status using GitHub CLI:
```bash
gh pr checks
```

Look for:
- ✅ Passing jobs
- ❌ Failing jobs
- ⏳ In-progress jobs

### 3. Handle Failures

When CI fails:

**Analyze**: Get failure details:
```bash
gh pr checks --watch  # Live monitoring
gh run view <run-id>  # Detailed logs
```

**Fix**: Based on the error:
- Linting errors → Fix code style issues
- Type errors → Fix TypeScript/type issues
- Test failures → Fix failing tests
- Build errors → Fix compilation issues

**Commit & Push**: Use gitmoji format:
```bash
git add .
git commit -m "🐛 fix <issue>"
git push
```

**Re-check**: Monitor again until passing

### 4. Success Criteria

Monitoring is complete when:
- All CI jobs show ✅
- User explicitly stops monitoring

### 5. Reporting

Provide clear status updates:
- "CI running: 3/5 jobs complete"
- "CI failed: TypeScript errors in `src/components/Button.tsx`"
- "CI passed: All checks green ✅"
