# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Med Assist is a Flutter medication management app with dose tracking, stock management, AI chatbot, analytics, OCR prescription scanning, and PDF/CSV report generation. Supports English and Arabic (RTL).

## Build & Development Commands

```bash
# Run app (debug)
flutter run

# Run all tests (~267 tests, ~10s)
flutter test

# Run specific test suite
flutter test test/unit
flutter test test/integration
flutter test test/widget
flutter test test/e2e

# Run single test file
flutter test test/unit/database/medication_crud_test.dart

# Test with coverage
flutter test --coverage

# Code generation (Drift models, flutter_gen assets)
flutter pub run build_runner build --delete-conflicting-outputs

# Localization generation (happens automatically, but can force with)
flutter gen-l10n

# Build release
flutter build apk --release
flutter build ios --release

# Analyze code
flutter analyze
```

## Architecture

**Feature-first Clean Architecture** with three layers:

- **`lib/core/`** — Database (Drift ORM), routing (GoRouter), theme (Material Design 3), constants, shared widgets
- **`lib/features/`** — 16 feature modules, each with screens/, providers/, widgets/, models/ as needed
- **`lib/services/`** — Cross-cutting business logic: AI, notifications, background tasks, OCR, export, etc.

### State Management

**Riverpod 3.0** is the primary state management. Providers live in `providers/` directories within each feature and in `lib/core/database/providers/`. `get_it` is used as a secondary service locator for singleton services (NotificationService, ErrorHandlerService, etc.).

### Database

**Drift (SQLite ORM)** with 5 tables: Medications, ReminderTimes, DoseHistory, StockHistory, SnoozeHistoryTable. Schema is at version 7 with incremental migrations in `lib/core/database/app_database.dart`.

**`MedicationRepository`** (`lib/core/database/repositories/medication_repository.dart`) is the single facade for all database operations. All dose-recording and stock-mutation logic uses database transactions. Both UI providers and background services share this repository — never bypass it with direct table queries.

### Routing

GoRouter configured in `lib/core/router/app_router.dart`. Route constants defined in `lib/core/constants/app_constants.dart`. Bottom navigation uses `MainScaffold` with tab indexes 0-3.

### Localization

ARB-based (`lib/l10n/`). Template is `app_en.arb`, Arabic in `app_ar.arb`. Config in `l10n.yaml`. Generated files: `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_ar.dart`.

### AI Services

`MultiAIService` (`lib/services/ai/`) implements a fallback chain: Groq → Gemini → HuggingFace. API keys loaded from `.env` via `flutter_dotenv`.

### App Initialization (main.dart)

Startup sequence: error zone → WidgetsBinding → dotenv → ErrorHandlerService → NotificationService → BackgroundService (WorkManager) → snooze history cleanup → permissions → ProviderScope launch.

## Code Style & Linting

Uses `very_good_analysis` 10.0.0 (strict lint rules). Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis. `public_member_api_docs` is disabled.

## Testing

Test helpers in `test/widget/helpers/`:
- `widget_test_helpers.dart` — `createTestDatabase()` (in-memory Drift DB), `createTestApp()`, common actions
- `test_data_factories.dart` — `createTestMedication()`, `createTestReminderTimes()`, bulk factories
- `app_widget_harness.dart` — Full app harness for widget tests

## Key Patterns

- **RepetitionPatternUtils** (`lib/core/utils/repetition_pattern_utils.dart`) — shared logic for medication scheduling patterns (daily, specific days, intervals)
- Singleton services use factory constructor pattern: `factory MyService() => _instance`
- HomeScreen uses `WidgetsBindingObserver` to refresh doses on app resume
- Notification scheduling requires timezone-aware DateTime handling (`timezone` + `flutter_timezone` packages)
