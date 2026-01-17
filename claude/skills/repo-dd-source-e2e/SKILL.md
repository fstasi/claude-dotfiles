---
name: repo-dd-source-e2e
description: E2E testing workflow for dd-source staging deployment
---

## E2E Testing Workflow for dd-source

Use this after CI has passed to test changes on staging.

### Step 1: Deploy Services to Staging

Deploy modified services by posting **individual comments** in the PR:

```
/integrate -s <service-name>
```

**Examples**:
- `/integrate -s entities-search-worker`
- `/integrate -s search-router`

**Important**: Post **separate comments** for each service deployment.

### Step 2: Monitor Integration

Monitor the integration deployment:
- Check PR for integration status comments
- Typical time: 5-10 minutes per service
- Wait for confirmation that deployment completed

### Step 3: Test the Staging Service

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

#### Example: Custom Query

Adjust the endpoint and payload based on your changes:
- **Endpoint**: `/api/unstable/<your-endpoint>`
- **Payload**: Match your proto/API contract

### Step 4: Verify Results

- Check response for expected behavior
- Compare with production if needed
- Report any issues found during testing
- Document successful test cases

### Step 5: Report Back

Provide test results:
- ✅ Successful test cases
- ❌ Issues found
- 📊 Performance observations
