---
name: repo-dd-source-e2e
description: E2E testing for dd-source on staging
context: fork
agent: general-purpose
---

## E2E Testing Workflow

Use after CI has passed to test changes on staging.

### Step 1: Deploy Services to Staging

Post **individual comments** in the PR for each service:

```
/integrate -s <service-name>
```

Examples:
- `/integrate -s entities-search-worker`
- `/integrate -s search-router`

### Step 2: Monitor Integration

- Check PR for integration status comments
- Wait 5-10 minutes per service
- Report progress: `"Deployment completed for entities-search-worker ✅"`

### Step 3: Test the Staging Service

```bash
curl -X POST https://search-router.us1.staging.dog/api/unstable/<endpoint> \
  -H "$(ddauth obo --orgId 2)" \
  --data '<request-payload>' | jq
```

Example (entities suggestions):
```bash
curl -X POST https://search-router.us1.staging.dog/api/unstable/entities/suggestions \
  -H "$(ddauth obo --orgId 2)" \
  --data '{"data":{"type":"entities_search_request","attributes":{"raw_query":"search", "limit":2, "suggestion_groups":["service"]}}}' | jq
```

### Step 4: Report Results

**Success:**
```
"✅ E2E testing completed!
- entities-search-worker ✅
- search-router ✅
- Entities suggestions: ✅ Returns expected results"
```

**Failure:**
```
"❌ E2E testing found issues:
- Entities suggestions: ❌ Returns 500 error
- Error: <message>"
```
