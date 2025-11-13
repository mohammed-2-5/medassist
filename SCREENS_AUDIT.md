# Screens Audit - Quick Reference

## ✅ ACTIVE & REACHABLE (17 screens)

| Screen | Route | Access Method | Status |
|--------|-------|---------------|--------|
| SplashScreen | `/splash` | App entry point | ✅ Working |
| EnhancedOnboardingScreen | `/onboarding` | First launch | ✅ Working |
| HomeScreen | `/` | Bottom nav index 0 | ✅ Working |
| MedicationsListScreen | `/medications` | Bottom nav index 1 | ✅ Working |
| AnalyticsDashboardScreen | `/analytics` OR `/history` ⚠️ | Bottom nav index 2 | ⚠️ Route mismatch |
| HistoryScreen | `/stock` ⚠️ | Bottom nav index 3 | ⚠️ Route mismatch |
| StockOverviewScreen | `/chatbot` ⚠️ | Bottom nav index 4 | ⚠️ Route mismatch |
| ChatbotScreen | (no direct route) | Bottom nav index 5 | ✅ Working via nav |
| MedicationDetailScreen | `/medication/:id` | Tap medication card | ✅ Working |
| MedicationEditScreen | `/medication/:id/edit` | Edit button in detail | ✅ Working |
| AddMedicationScreen | `/add-medication` | FAB (+) button | ✅ Working |
| Step1TypeInfo | (internal) | Used by AddMedicationScreen | ✅ Working |
| Step2Schedule | (internal) | Used by AddMedicationScreen | ✅ Working |
| Step3Stock | (internal) | Used by AddMedicationScreen | ✅ Working |
| ReportsScreen | `/reports` | Linked from analytics | ✅ Working |
| InsightsScreen | `/insights` | Linked from home | ✅ Working |
| SettingsScreen | `/settings` | App bar icon | ✅ Working |
| DiagnosticsScreen | `/diagnostics` | Settings menu | ✅ Working |
| NotificationDebugScreen | (no route) | Navigator.push from Settings | ⚠️ Old navigation |

**Total Active: 19 components**

---

## ❌ DEAD CODE / UNREACHABLE (9 screens)

| Screen | File Path | Reason | Action |
|--------|-----------|--------|--------|
| AddMedicationWizardScreen | `add_medication/screens/add_medication_wizard_screen.dart` | Replaced by AddMedicationScreen | 🗑️ DELETE |
| Step1MedicineTypeScreen | `add_medication/screens/step1_medicine_type_screen.dart` | Replaced by Step1TypeInfo | 🗑️ DELETE |
| Step2MedicineNameScreen | `add_medication/screens/step2_medicine_name_screen.dart` | Old wizard step | 🗑️ DELETE |
| Step3DosageScheduleScreen | `add_medication/screens/step3_dosage_schedule_screen.dart` | Old wizard step | 🗑️ DELETE |
| Step4StockRefillScreen | `add_medication/screens/step4_stock_refill_screen.dart` | Old wizard step | 🗑️ DELETE |
| OnboardingScreen | `onboarding/screens/onboarding_screen.dart` | Replaced by EnhancedOnboardingScreen | 🗑️ DELETE |
| RemindersScreen | `reminders/screens/reminders_screen.dart` | No route, placeholder | 🗑️ DELETE or ADD ROUTE |
| ExportScreen | `export/screens/export_screen.dart` | No route, feature exists | 🔧 ADD ROUTE or MERGE |
| MediBotChatScreen | `medibot/screens/medibot_chat_screen.dart` | Empty stub, duplicate | 🗑️ DELETE |

**Total Dead: 9 files**

---

## 🔴 CRITICAL BUGS

### Bug #1: Route Index Mismatch
**Location:** `lib/core/router/app_router.dart` lines 54-67

**Problem:**
```dart
// Current (WRONG)
GoRoute(path: '/history', ...) → MainScaffold(initialIndex: 2) → AnalyticsDashboardScreen ❌
GoRoute(path: '/stock', ...) → MainScaffold(initialIndex: 3) → HistoryScreen ❌
GoRoute(path: '/chatbot', ...) → MainScaffold(initialIndex: 4) → StockOverviewScreen ❌
```

**Expected:**
```dart
// Should be
GoRoute(path: '/history', ...) → MainScaffold(initialIndex: 3) → HistoryScreen ✅
GoRoute(path: '/stock', ...) → MainScaffold(initialIndex: 4) → StockOverviewScreen ✅
GoRoute(path: '/chatbot', ...) → MainScaffold(initialIndex: 5) → ChatbotScreen ✅
```

**Impact:**
- Users navigating via deep links or external routes will see wrong screens
- Confusing for developers and users

---

### Bug #2: Duplicate Chatbot Screens
**Locations:**
- `lib/features/chatbot/screens/chatbot_screen.dart` (WORKING - has Gemini AI)
- `lib/features/medibot/screens/medibot_chat_screen.dart` (EMPTY STUB)

**Problem:** Two chatbot implementations:
1. `ChatbotScreen` - Fully functional with AI integration
2. `MediBotChatScreen` - Has route `/medibot` but is empty TODO

**Impact:** Wasted code, confusion, potential bugs

**Fix:** Delete `MediBotChatScreen` and remove `/medibot` route

---

### Bug #3: NotificationDebugScreen Uses Old Navigation
**Location:** `lib/features/settings/screens/settings_screen.dart:137`

**Problem:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NotificationDebugScreen()),
)
```

**Impact:**
- Inconsistent navigation (rest of app uses GoRouter)
- Back button behavior may be inconsistent
- Can't use deep links

**Fix:** Add route and use `context.push('/diagnostics/notifications')`

---

## 📊 CODE HEALTH METRICS

- **Total Screen Files:** 28
- **Active & Used:** 19 (68%)
- **Dead/Unreachable:** 9 (32%)
- **Bugs Found:** 3 critical
- **Lines of Dead Code:** ~1,500+ (estimate)

---

## 🛠️ CLEANUP CHECKLIST

### Step 1: Fix Critical Bug (Route Mismatch) ⚠️ HIGH PRIORITY
```dart
// File: lib/core/router/app_router.dart

// Change from:
GoRoute(path: '/history', builder: (context, state) => const MainScaffold(initialIndex: 2)),
GoRoute(path: '/stock', builder: (context, state) => const MainScaffold(initialIndex: 3)),
GoRoute(path: '/chatbot', builder: (context, state) => const MainScaffold(initialIndex: 4)),

// To:
GoRoute(path: '/history', builder: (context, state) => const MainScaffold(initialIndex: 3)),
GoRoute(path: '/stock', builder: (context, state) => const MainScaffold(initialIndex: 4)),
GoRoute(path: '/chatbot', builder: (context, state) => const MainScaffold(initialIndex: 5)),
```

### Step 2: Delete Old Wizard Files
```bash
# Delete these 5 files:
rm lib/features/add_medication/screens/add_medication_wizard_screen.dart
rm lib/features/add_medication/screens/step1_medicine_type_screen.dart
rm lib/features/add_medication/screens/step2_medicine_name_screen.dart
rm lib/features/add_medication/screens/step3_dosage_schedule_screen.dart
rm lib/features/add_medication/screens/step4_stock_refill_screen.dart
```

### Step 3: Delete Old Onboarding
```bash
rm lib/features/onboarding/screens/onboarding_screen.dart
```

### Step 4: Remove Duplicate Chatbot
```bash
# Delete the empty stub
rm lib/features/medibot/screens/medibot_chat_screen.dart
rm -rf lib/features/medibot/  # if directory is now empty

# Remove from router (app_router.dart lines 109-114)
# Delete:
#   GoRoute(
#     path: '/medibot',
#     name: 'medibot',
#     builder: (context, state) => const MediBotChatScreen(),
#   ),
```

### Step 5: Handle ExportScreen
**Option A:** Add route if feature is needed
```dart
GoRoute(
  path: '/export',
  name: 'export',
  builder: (context, state) => const ExportScreen(),
),
```

**Option B:** Delete if functionality is covered by ReportsScreen
```bash
rm lib/features/export/screens/export_screen.dart
```

### Step 6: Handle RemindersScreen
**Decision Needed:** Feature appears to be covered by HistoryScreen

**Option A:** Delete
```bash
rm lib/features/reminders/screens/reminders_screen.dart
```

**Option B:** Implement as separate feature with route

### Step 7: Migrate NotificationDebugScreen to GoRouter
```dart
// In app_router.dart, add:
GoRoute(
  path: '/diagnostics/notifications',
  name: 'notification-debug',
  builder: (context, state) => const NotificationDebugScreen(),
),

// In settings_screen.dart, change:
// From:
Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationDebugScreen()));

// To:
context.push('/diagnostics/notifications');
```

---

## 📈 EXPECTED RESULTS AFTER CLEANUP

- **Files Deleted:** 8-9
- **Lines of Code Reduced:** ~1,500+
- **Bugs Fixed:** 3
- **Navigation Consistency:** 100%
- **Code Health:** A+ (no dead code)

---

## ⚙️ TESTING CHECKLIST AFTER FIXES

- [ ] App launches successfully
- [ ] `/history` route shows HistoryScreen
- [ ] `/stock` route shows StockOverviewScreen
- [ ] `/chatbot` route shows ChatbotScreen
- [ ] Bottom navigation works for all 6 tabs
- [ ] Settings → Debug Notifications works with GoRouter
- [ ] No import errors after file deletions
- [ ] `flutter analyze` shows no errors
- [ ] Build succeeds

---

Generated: 2025-01-11
Status: Analysis Complete - Awaiting Action
