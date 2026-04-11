# Run Tests

Run the full test suite and summarize results. Show:
1. Total passed / failed / skipped
2. Any failing tests with their error messages
3. Note the two known pre-existing failures (groqService late init ~78 tests, medication_management_test null safety 1 test) — do NOT flag these as new issues

```bash
flutter test --reporter=compact
```

If $ARGUMENTS is provided, run only that test path:
```bash
flutter test $ARGUMENTS --reporter=compact
```
