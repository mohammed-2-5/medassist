# Run Code Generation

Run Drift + flutter_gen code generation for Med Assist.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Then regenerate localizations:
```bash
flutter gen-l10n
```

Report any errors. Common issues:
- Drift: missing `part` directive in table file
- flutter_gen: pubspec.yaml assets section out of date
- l10n: malformed ARB JSON or missing required keys
