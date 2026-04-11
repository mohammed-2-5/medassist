# Split Large Widget

Split a large widget file into smaller, well-organized pieces following Med Assist conventions.

Target file: $ARGUMENTS

Steps:
1. Read the file and identify logical sub-components (sections of `build()`, repeated subtrees, inline builders)
2. For each extracted widget decide:
   - Does it belong in the same file? (small private widget `_MyWidget`)
   - Does it need its own file in `widgets/`? (reusable or >40 lines)
3. Extract in-place first, then move to separate files if needed
4. Naming: use `_` prefix for private widgets in same file, PascalCase file names for separate files
5. Keep state in the parent or provider — extracted widgets should be stateless where possible

Rules:
- Do NOT change behavior, only restructure
- Keep all existing imports and do not break the public API of the original widget
- After splitting, verify `flutter analyze` would pass (no unused imports, const correctness)
