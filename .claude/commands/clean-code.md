# Clean Code Review

Review $ARGUMENTS for clean code issues specific to this Flutter/Dart project.

Read the target file(s) and check:

### Dart / Flutter specifics
- Missing `const` constructors where possible
- `BuildContext` used across async gaps without `mounted` check
- Large `build()` methods — anything over ~60 lines should be split into sub-widgets
- Business logic inside `build()` — move to provider or controller
- Magic numbers/strings — extract to constants in `lib/core/constants/app_constants.dart`
- Repeated widget subtrees (3+ times) — extract to a named widget

### Riverpod
- `.read(provider)` inside `build()` — use `.watch()` or `ref.listen`
- Providers that do too much — split by responsibility
- Missing `autoDispose` on providers that hold temporary state

### General
- Functions longer than ~30 lines — split them
- Nested callbacks deeper than 2 levels — extract named functions
- Dead code: unused variables, imports, or methods
- Commented-out code blocks — remove or convert to TODO with ticket

For each issue: file:line, what the problem is, and the fix. Skip issues in generated files (`*.g.dart`, `*.freezed.dart`).
