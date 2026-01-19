---
name: repo-web-ui-rules
description: Conventions and testing rules for web-ui repository
---

## web-ui Repository Conventions

These rules apply when working in the web-ui repository.

### Base Branch

**Important**: The web-ui repository uses `preprod` as the base branch, NOT `main`.

- Rebase against: `preprod`
- Compare changes against: `origin/preprod`
- Create PRs targeting: `preprod`

### Static Hash Link for Testing

After creating a PR, the CI system generates a static hash for testing the changes.

#### Retrieving the Static Hash

Wait for the CI build to complete and retrieve the static hash from the build artifacts or CI output.

#### URL Formats for Testing

**Base URL**:
```
https://app-<static-hash>.datadoghq.com/dashboard/lists?p=1
```

**With RUM changes** (append `&enable-rum=1`):
```
https://app-<static-hash>.datadoghq.com/dashboard/lists?p=1&enable-rum=1
```

**With feature flags** (append `&set_config_<flag-name>=true`):
```
https://app-<static-hash>.datadoghq.com/dashboard/lists?p=1&set_config_<flag-name>=true
```

**Combined example** (RUM + feature flag):
```
https://app-<static-hash>.datadoghq.com/dashboard/lists?p=1&enable-rum=1&set_config_sxs-shadow-traffic=true
```

#### When to Include Testing URLs

Check the Jira issue to determine:
- Does it involve RUM changes? → Add `&enable-rum=1`
- Does it require feature flags? → Add `&set_config_<flag-name>=true`
- Adjust the endpoint path based on what's being tested (e.g., `/dashboard/lists`, `/logs`, etc.)

#### Adding to PR Description

Update the PR description's **QA section** with the appropriate testing URL once the static hash is available.
