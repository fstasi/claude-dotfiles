---
description: Rules, commands, and E2E testing for dd-source repository (search-experience domain)
priority: 1
user-invocable: true
trigger:
  - pattern: "dd-source"
    description: Loaded when working in dd-source repo
  - pattern: "search.experience"
    description: Loaded for search-experience domain work
  - pattern: "entities.*worker"
    description: Loaded for entity service work
  - pattern: "search.router"
    description: Loaded for search-router work
  - pattern: "e2e.*(test|staging)"
    description: Invoked for E2E testing
  - pattern: "test.*(staging|integrate)"
    description: Invoked when testing on staging
---

## dd-source Repository Rules

These rules apply to changes in the search-experience domain.

### Service Changes

When working on a service (entity service, logs service, etc.), consider changes to both:
- The specific worker (e.g., `entities-search-worker`)
- The `search-router`

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

Always run tests when possible:
```bash
bzl test domains/search_experiences/...
```

---

## E2E Testing Workflow

Use this after CI has passed to test changes on staging.

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
