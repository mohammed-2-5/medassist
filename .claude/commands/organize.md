# File Organization Check

Audit the file and folder organization of $ARGUMENTS (or the whole `lib/` if no argument given).

**Expected structure per feature:**
```
lib/features/<feature>/
  screens/      — Full-page widgets registered in GoRouter
  providers/    — Riverpod providers and state notifiers
  widgets/      — Reusable widgets scoped to this feature
  models/       — Local-only models (only if not in Drift DB)
  controllers/  — Complex logic not suited for providers (optional)
  utils/        — Feature-scoped helpers (optional)
```

**Expected structure for core:**
```
lib/core/
  constants/    — App-wide constants
  database/     — Drift tables, repository, migrations, models
  errors/       — Error handling service
  navigation/   — MainScaffold, bottom nav
  router/       — GoRouter config
  theme/        — AppTheme, colors, text styles
  utils/        — Shared utilities (e.g., RepetitionPatternUtils)
  widgets/      — Shared widgets used across features
```

**Check for:**
1. Files in the wrong layer (e.g., a widget in `screens/`, a provider in `widgets/`)
2. Feature-specific code living in `lib/core/`
3. Shared code duplicated across features instead of moved to `lib/core/`
4. Files that grew too large (>300 lines) and should be split
5. Orphaned files with no imports pointing to them

Run this to find unused files:
```bash
# Find dart files not imported anywhere
grep -rL "import" lib/ --include="*.dart" | grep -v "main.dart" | grep -v ".g.dart"
```

Report misplaced files with the correct destination path.
