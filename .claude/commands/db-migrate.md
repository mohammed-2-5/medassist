# Database Migration

Help add a new Drift database migration for Med Assist.

Context: Schema is currently at version 7. Migrations live in `lib/core/database/app_database.dart` inside `MigrationStrategy`.

Steps:
1. Read `lib/core/database/app_database.dart` to see current schema version and migration history
2. Determine the next version number
3. Add the new table/column/change to the appropriate `@DataClassName` table class
4. Add a `from vN to vN+1` migration step in `MigrationStrategy.onUpgrade`
5. Bump `schemaVersion` constant
6. Run code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Describe what change is needed: $ARGUMENTS
