# Scaffold New Feature

Scaffold a new feature module for Med Assist following the existing feature-first clean architecture.

Feature name: $ARGUMENTS

Create the directory structure under `lib/features/$ARGUMENTS/`:
```
lib/features/<name>/
  screens/         — Screen widgets (GoRouter targets)
  providers/       — Riverpod providers
  widgets/         — Feature-specific widgets
```

Also:
- Add a route constant in `lib/core/constants/app_constants.dart`
- Add the route in `lib/core/router/app_router.dart`
- If the feature needs a bottom nav tab, add it to `lib/core/navigation/main_scaffold.dart`

Follow the same patterns as existing features (e.g., `lib/features/medications/`). Do not create models/ unless the feature truly needs local-only models not in the DB.
