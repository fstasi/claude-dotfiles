---
name: repo-dd-source-rules
description: Build commands and conventions for dd-source repository (search-experience domain)
---

## dd-source Repository Conventions

These rules apply to changes in the search-experience domain.

### API & Service Changes

When making changes that impact the API (proto definitions), updates propagate to both:
- The specific worker (e.g., `entities-search-worker`)
- The `search-router`

Ensure both are updated and tested when modifying protos.

### Proto Updates

After updating proto files, regenerate Go code:
```bash
bzl run //:snapshot -- domains/search_experiences/...
```

### Import Updates

After updating imports, regenerate bzl files:
```bash
bzl run //:gazelle
```

### Unit Testing

Run tests before every commit:
```bash
bzl test domains/search_experiences/...
```

If tests fail, fix them before committing.

### Build Command

Full build with tests:
```bash
bzl test domains/search_experiences/...
```

### E2E Testing

After CI passes, run E2E tests on staging.

#### Step 1: Deploy Services to Staging

Post **individual comments** in the PR for each service:

```
/integrate -s <service-name>
```

Examples:
- `/integrate -s entities-search-worker`
- `/integrate -s search-router`

#### Step 2: Monitor Integration

- Check PR for integration status comments
- Wait 5-10 minutes per service
- Report progress: `"Deployment completed for entities-search-worker ✅"`

#### Step 3: Test the Staging Service

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

#### Step 4: Report Results

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
