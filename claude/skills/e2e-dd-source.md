---
description: E2E test changes on a dd-source branch after CI passes
priority: 1
user-invocable: true
trigger:
  - pattern: "e2e.*(test|dd-source|staging)"
    description: Automatically invoked for E2E testing on dd-source
  - pattern: "test.*(staging|integrate)"
    description: Invoked when testing on staging environment
---

## E2E Testing Workflow for dd-source

Use this skill to E2E test changes on a dd-source branch **after CI has passed**.

### 1. Deploy Services to Staging

Deploy modified services by posting **individual comments** in the PR:

```
/integrate -s <service-name>
```

**Examples**:
- `/integrate -s entities-search-worker`
- `/integrate -s search-router`

**Important**: Post **separate comments** for each service deployment.

### 2. Monitor Integration

Use `dd:fetch-ci-results` skill to:
- Poll until integration(s) complete
- Typical time: 5-10 minutes per service
- Report back when ready

### 3. Test the Staging Service

Once integration is complete, test via the router:

```bash
curl -X POST https://search-router.us1.staging.dog/api/unstable/<endpoint> \
  -H "$(ddauth obo --orgId 2)" \
  --data '<request-payload>' | jq
```

#### Example: Entities Suggestions

```bash
curl -X POST https://search-router.us1.staging.dog/api/unstable/entities/suggestions \
  -H "$(ddauth obo --orgId 2)" \
  --data '{"data":{"type":"entities_search_request","attributes":{"raw_query":"search", "limit":2, "suggestion_groups":["service"]}}}' | jq
```

### 4. Verify Results

- Check response for expected behavior
- Compare with production if needed
- Report any issues found during testing
- Document successful test cases
