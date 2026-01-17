---
description: Rules and commands for working in dd-source repository (search-experience domain)
priority: 1
trigger:
  - pattern: "dd-source"
    description: Loaded when working in dd-source repo
  - pattern: "search.experience"
    description: Loaded for search-experience domain work
  - pattern: "entities.*worker"
    description: Loaded for entity service work
  - pattern: "search.router"
    description: Loaded for search-router work
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

### Testing

Always run tests when possible:
```bash
bzl test domains/search_experiences/...
```
