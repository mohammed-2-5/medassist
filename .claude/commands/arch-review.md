# Architecture Review

Review a file or feature module for architectural correctness against Med Assist's feature-first clean architecture.

Target: $ARGUMENTS (file path or feature name, e.g. `lib/features/home` or `lib/features/stock/providers/stock_providers.dart`)

**Check these rules:**

### Layer boundaries
- Screens must NOT import from other feature's screens directly — use GoRouter routes
- Providers must NOT contain UI logic (BuildContext, Widget refs)
- Widgets must NOT directly query the database — go through providers
- Services (`lib/services/`) must NOT import feature-specific providers or widgets
- `lib/core/` must NOT import from `lib/features/`

### Repository rule
- Any dose recording or stock mutation must go through `MedicationRepository`
- No direct Drift table queries (`.select()`, `.insertReturning()`, etc.) outside of `MedicationRepository`

### State management
- State must live in Riverpod providers — not in widget `setState` for shared state
- `get_it` is only for singleton services (NotificationService, ErrorHandlerService, etc.)
- No provider defined inside a widget file

### Dependency direction
```
screens → providers → repository → database
widgets → providers
services ← providers (services don't depend on providers)
```

Report each violation with file:line and how to fix it.
