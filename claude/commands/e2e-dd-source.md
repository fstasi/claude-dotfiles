---
description: E2E test changes on a dd-source branch
---

## E2E Testing Workflow for dd-source

Use this command to E2E test changes on a dd-source branch after CI has passed.

### 1. Deploy Services to Staging

Deploy the modified services/workers by posting individual comments in the PR:

- `/integrate -s <service-name>` - integrates and deploys a single service
- Examples:
  - `/integrate -s entities-search-worker` - deploy entities-search-worker
  - `/integrate -s search-router` - deploy search-router

**Important:** To deploy multiple services, post separate comments for each service.

### 2. Monitor Integration

use `dd:fetch-ci-results` skill to check CI status:
- Poll periodically until the integrations(s) complete
- Integration typically takes 5-10 minutes per service
- report back to the main agent

### 3. Test the Staging Service

Once integration is complete, test the service through the router using curl:

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

- Check the response for expected behavior
- Compare with production if needed
- Report any issues found during testing
