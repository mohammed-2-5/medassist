# Repository Guidelines

## Project Structure & Module Organization
Med Assist is a Flutter 3.24 app with a feature-first `lib/` layout: `core` for utilities, `constants` for design tokens, `services` for AI, health, and notification gateways, and `features/*` for user-facing flows. Drift tables, generated widgets, and router files stay next to their owners and are rebuilt through `build_runner`. Platform shells live in `android/`, `ios/`, `macos/`, `web/`, and `windows/`; shared fonts and images remain in `assets/`. Tests mirror production paths across `test/unit`, `test/widget`, `test/integration`, and `test/e2e`, so drop new fixtures into the matching folder.

## Build, Test, and Development Commands
Run `flutter pub get` after cloning or changing `pubspec.yaml`. Recreate database and localization code via `flutter pub run build_runner build --delete-conflicting-outputs`. Use `flutter analyze` and `dart format .` to satisfy `very_good_analysis`. Start local development with `flutter run -d <device>`; ship builds through `flutter build apk --release` (or the equivalent for iOS/web/desktop). Execute `flutter test --coverage` for unit+widget suites and `flutter test integration_test` or `flutter drive --driver=test_driver/integration_test.dart` for device flows.

## Coding Style & Naming Conventions
Adhere to the lint rules in `analysis_options.yaml`. Stick to 2-space indentation, trailing commas in widget trees, and explicit return types. Name files in `snake_case.dart`, classes/widgets in `PascalCase`, and Riverpod providers with the `*_provider.dart` suffix. Favor immutable models, keep platform-specific plugins behind adapters, and document non-trivial logic with terse comments.

## Testing Guidelines
Coverage surpasses 260 specs; do not regress it. Mirror source directories when naming tests (e.g., `lib/features/analytics/...` -> `test/unit/features/analytics/...`). Widget and golden tests rely on `golden_toolkit`; capture scenarios in `test/widget`. Integration and e2e suites under `test/integration` and `test/e2e` must run on hardware that allows background notifications. Add regression tests whenever you touch reminders, AI services, or database migrations.

## Commit & Pull Request Guidelines
Follow Conventional Commits (`feat:`, `fix:`, `docs:`) as seen in `git log`. Keep commits focused and reference GitHub issues or roadmap IDs when relevant. Every PR should summarize scope, list the commands you ran (`flutter analyze`, `flutter test`, device targets), and include screenshots or recordings for UI updates. Mention new `.env` keys, update documentation when behavior changes, and request reviews before merging.

## Security & Configuration Tips
Populate secrets via `.env` (see `.env.example`) and never commit real keys for Gemini, Groq, or HuggingFace. Clear generated files before commit by rerunning `build_runner` so reviewers see deterministic diffs. When exporting health data or logs, store them inside app-specific directories and scrub them after debugging sessions.


