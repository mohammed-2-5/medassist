# Check 250-Line Compliance

Scan all Dart files in the project and report violations of the 250-line rule.

```bash
find lib -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "app_localizations*.dart" | xargs wc -l | sort -rn | awk '$1 > 250 && $2 != "total"'
```

For each violating file, also check:
- How many classes/widgets are defined in it
- What could be extracted (widgets, utils, models, logic)

```bash
# Count class definitions per file
grep -c "^class \|^ *class " lib/**/*.dart 2>/dev/null | grep -v ":0" | grep -v ".g.dart"
```

Output a prioritized list:
1. Files with BOTH multiple classes AND over 250 lines (highest priority)
2. Files over 500 lines (critical)
3. Files 250–500 lines with multiple classes (high)
4. Files 250–500 lines with one class (medium — may just need logic extraction)

Suggest which `/refactor-file` calls to run first.
