---
name: repo-dd-source-rules
description: Build commands and conventions for dd-source repository (search-experience domain)
---

## dd-source Repository Conventions

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

### Build Command

Full build with tests:
```bash
bzl test domains/search_experiences/...
```
