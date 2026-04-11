# Build Release APK

Build a release APK for Med Assist.

1. First run analyze to catch any errors:
```bash
flutter analyze
```

2. If analyze passes (or only has warnings), build:
```bash
flutter build apk --release
```

3. Report the output APK path and file size.

If $ARGUMENTS is `aab`, build an App Bundle instead:
```bash
flutter build appbundle --release
```
