---
name: repo-dd-source-e2e
description: E2E testing workflow for dd-source staging deployment (runs as background agent)
---

## ⚠️ IMPORTANT: This Workflow Runs as a Background Agent

**This skill describes a workflow that should be executed by a background agent**, not the main conversation agent. This keeps the main context clean and lean.

### How the Main Agent Should Invoke This

When E2E testing is needed, the main agent should:

1. **Spawn a background agent** using the Task tool:
   ```
   Task tool with:
   - subagent_type: "general-purpose"
   - run_in_background: true
   - prompt: "Run E2E testing for dd-source PR <PR-URL>. Follow the repo-dd-source-e2e skill. Deploy services to staging, test the endpoints, and report back with results."
   ```

2. **Inform the user**:
   ```
   "I've spawned a background agent to run E2E tests on staging. It will deploy the services, test them, and report back with results. This may take 10-15 minutes. You can continue working on other tasks."
   ```

3. **Continue with other work** - don't block waiting for E2E tests

---

## E2E Testing Workflow for dd-source (For Background Agent)

This section is executed by the background agent.

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

**Report progress to main conversation:**
```
"Deployment started for entities-search-worker... waiting for completion"
"Deployment completed for entities-search-worker ✅"
```

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

### Step 5: Report Back to Main Conversation

Provide comprehensive test results:

**Success:**
```
"✅ E2E testing completed successfully on staging!

Deployed services:
- entities-search-worker ✅
- search-router ✅

Test results:
- Entities suggestions endpoint: ✅ Returns expected results
- Performance: Response time ~200ms

All tests passed!"
```

**Failure:**
```
"❌ E2E testing found issues on staging:

Deployed services:
- entities-search-worker ✅
- search-router ✅

Test results:
- Entities suggestions endpoint: ❌ Returns 500 error
- Error: <error message>

Investigation needed."
```
