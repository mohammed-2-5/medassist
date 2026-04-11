# Full Architecture Audit

Run a comprehensive architecture, clean code, and organization audit across the entire codebase.

This combines `/arch-review`, `/clean-code`, and `/organize` into one full pass.

## Step 1 — Layer violation scan
Search for cross-layer imports that break the architecture:

```bash
# Features importing other features' screens
grep -r "import.*features.*screens" lib/features --include="*.dart" -l

# Core importing features
grep -r "import.*features" lib/core --include="*.dart" -l

# Direct DB table queries outside repository
grep -r "\.select()\|\.insertReturning\|\.deleteWhere\|into(.*).insert" lib --include="*.dart" -l | grep -v "medication_repository"
```

## Step 2 — Provider hygiene
```bash
# BuildContext in providers
grep -r "BuildContext" lib/features --include="*.dart" -l | grep "provider"

# get_it used for non-services
grep -r "GetIt\|locator\|sl\." lib/features --include="*.dart" -l
```

## Step 3 — Widget size check
```bash
# Files over 300 lines (candidates for splitting)
find lib -name "*.dart" | xargs wc -l | sort -rn | head -20
```

## Step 4 — Localization gaps
```bash
# Hardcoded English strings in widget files (rough check)
grep -rn '"[A-Z][a-z ]\{4,\}"' lib/features --include="*.dart" | grep -v "//\|\.arb\|test"
```

Summarize all findings by category with severity (critical / warning / suggestion). Prioritize critical layer violations first.
