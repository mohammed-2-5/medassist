# Refactor Entire Feature Module

Refactor all files in `lib/features/$ARGUMENTS/` to comply with one-class-per-file and 250-line rules.

**Rules:**
1. One public class/widget per file — no exceptions
2. UI (screens/widgets) ≤ 250 lines
3. Logic (providers) ≤ 250 lines
4. `_PrivateWidget` or `_buildX()` helpers → own files in `widgets/`
5. Business logic inside widgets → Riverpod providers
6. Helper lists/constants/formatters → `utils/` files
7. Inline data classes/maps → `models/` files

**Process:**
1. List all files in the feature with their line counts
2. For each file over 250 lines or containing multiple classes:
   a. Read the file
   b. Identify all extractions needed
   c. Create extracted files
   d. Update the source file
   e. Fix all imports
3. Verify every file in the feature is ≤ 250 lines with one class

**Order of operations:**
- Extract models first (no dependencies)
- Extract utils second (may depend on models)
- Extract widgets third (may depend on utils)
- Refactor providers last (may depend on all above)

Do NOT change behavior — structural extraction only. Run `flutter analyze` mentally to ensure no broken imports.
