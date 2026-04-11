# Refactor File — One Class Per File

Refactor $ARGUMENTS to comply with the project's strict file structure rules.

**Rules to enforce:**
1. One public class/widget per file
2. UI files ≤ 250 lines, logic files ≤ 250 lines
3. Every `_PrivateWidget` or inline sub-widget → own file in `widgets/`
4. Every helper `void _buildX()` → extracted widget in `widgets/`
5. Business logic in widgets → moved to Riverpod provider
6. Helper lists/maps/constants → `utils/` file
7. Inline data structures → `models/` or `lib/core/database/models/`

**Process:**
1. Read the target file fully
2. Identify everything that violates the rules above
3. Plan the extraction: list each extracted piece and its destination file
4. Execute: create new files, update imports, trim original file
5. Verify: original file is ≤ 250 lines, each new file has exactly one class/widget

**Extraction destinations:**
- Widget → `lib/features/<feature>/widgets/<widget_name>.dart`
- Provider logic → `lib/features/<feature>/providers/<name>_provider.dart`
- Utils → `lib/features/<feature>/utils/<name>_utils.dart` or `lib/core/utils/`
- Models → `lib/features/<feature>/models/<name>.dart` or `lib/core/database/models/`

Do NOT change any behavior — pure structural extraction only.
