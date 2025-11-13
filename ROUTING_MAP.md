# MedAssist App - Routing & Screens Map

## 📍 ROUTING STRUCTURE

### ✅ ACTIVE ROUTES (Defined in app_router.dart)

#### **Onboarding Flow**
- `/splash` → `SplashScreen` ✅
  - Entry point, checks first launch
- `/onboarding` → `EnhancedOnboardingScreen` ✅
  - 3-page tutorial for new users

#### **Main App (Bottom Navigation via MainScaffold)**
- `/` → `MainScaffold(index: 0)` → `HomeScreen` ✅
  - Today's medications, upcoming doses, quick actions
- `/medications` → `MainScaffold(index: 1)` → `MedicationsListScreen` ✅
  - List of all medications with search/filter
- `/history` → `MainScaffold(index: 2)` → `AnalyticsDashboardScreen` ✅
  - **NOTE: Mismatch! Route name suggests history but shows analytics**
- `/stock` → `MainScaffold(index: 3)` → `HistoryScreen` ✅
  - **NOTE: Mismatch! Route name suggests stock but shows history**
- `/chatbot` → `MainScaffold(index: 4)` → `StockOverviewScreen` ✅
  - **NOTE: Mismatch! Route name suggests chatbot but shows stock**

**⚠️ CRITICAL ISSUE: Bottom Navigation Indices Don't Match Routes!**

#### **MainScaffold Bottom Navigation (Actual Order)**
```
Index 0: HomeScreen
Index 1: MedicationsListScreen
Index 2: AnalyticsDashboardScreen (labeled "Reports" in UI)
Index 3: HistoryScreen (labeled "Reminders" in UI)
Index 4: StockOverviewScreen (labeled "Stock")
Index 5: ChatbotScreen (labeled "AI Chat")
```

#### **Medication Management**
- `/medication/:id` → `MedicationDetailScreen` ✅
  - View medication details, history, actions
- `/medication/:id/edit` → `MedicationEditScreen` ✅
  - Edit existing medication
- `/add-medication` → `AddMedicationScreen` ✅
  - 3-step wizard to add new medication
  - Uses: Step1TypeInfo, Step2Schedule, Step3Stock

#### **Features & Utilities**
- `/analytics` → `AnalyticsDashboardScreen` ✅
  - Charts and statistics (also accessible via bottom nav index 2)
- `/reports` → `ReportsScreen` ✅
  - Generate PDF/CSV reports
- `/insights` → `InsightsScreen` ✅
  - AI-powered medication insights
- `/medibot` → `MediBotChatScreen` ⚠️
  - **STUB! Empty TODO placeholder, never used**
- `/settings` → `SettingsScreen` ✅
  - App settings, theme, language
- `/diagnostics` → `DiagnosticsScreen` ✅
  - Notification testing and debugging

---

## ❌ UNREACHABLE SCREENS (Not in Router)

### **Old Wizard System (Deprecated)**
These appear to be from an old 4-step wizard that was replaced:

1. ❌ `AddMedicationWizardScreen`
   - Location: `lib/features/add_medication/screens/add_medication_wizard_screen.dart`
   - **Status:** Dead code, replaced by `AddMedicationScreen`

2. ❌ `Step1MedicineTypeScreen`
   - Location: `lib/features/add_medication/screens/step1_medicine_type_screen.dart`
   - **Status:** Dead code, replaced by `Step1TypeInfo`

3. ❌ `Step2MedicineNameScreen`
   - Location: `lib/features/add_medication/screens/step2_medicine_name_screen.dart`
   - **Status:** Dead code

4. ❌ `Step3DosageScheduleScreen`
   - Location: `lib/features/add_medication/screens/step3_dosage_schedule_screen.dart`
   - **Status:** Dead code

5. ❌ `Step4StockRefillScreen`
   - Location: `lib/features/add_medication/screens/step4_stock_refill_screen.dart`
   - **Status:** Dead code

### **Missing Route Definitions**

6. ❌ `RemindersScreen`
   - Location: `lib/features/reminders/screens/reminders_screen.dart`
   - **Status:** Placeholder, no route defined
   - **Issue:** Not integrated into navigation

7. ❌ `ExportScreen`
   - Location: `lib/features/export/screens/export_screen.dart`
   - **Status:** No route defined
   - **Functionality:** Export data to PDF/CSV
   - **Issue:** Should be accessible from Settings or Reports

8. ❌ `OnboardingScreen` (old version)
   - Location: `lib/features/onboarding/screens/onboarding_screen.dart`
   - **Status:** Replaced by `EnhancedOnboardingScreen`
   - **Issue:** Dead code

### **Special Cases**

9. ⚠️ `NotificationDebugScreen`
   - Location: `lib/features/settings/screens/notification_debug_screen.dart`
   - **Status:** Accessible only via `Navigator.push` from SettingsScreen
   - **Access:** Settings → Advanced → Debug Notifications
   - **Issue:** Not in router, uses old navigation

10. ⚠️ `MediBotChatScreen` (stub)
    - Location: `lib/features/medibot/screens/medibot_chat_screen.dart`
    - **Status:** Has route `/medibot` but is empty placeholder
    - **Issue:** Dead/incomplete feature
    - **Duplicate:** `ChatbotScreen` (fully implemented) already exists!

---

## 🔍 ISSUES FOUND

### 🔴 Critical Issues

1. **Route/Screen Mismatch in MainScaffold**
   ```
   /history → shows AnalyticsDashboardScreen (should show HistoryScreen)
   /stock → shows HistoryScreen (should show StockOverviewScreen)
   /chatbot → shows StockOverviewScreen (should show ChatbotScreen)
   ```

2. **Duplicate Chatbot Implementations**
   - `ChatbotScreen` (fully working with Gemini AI) - in bottom nav
   - `MediBotChatScreen` (empty stub) - has route but unused
   - **Action Needed:** Remove stub or implement it

### 🟡 Medium Priority Issues

3. **Dead Code from Old Wizard**
   - 5 unused screen files taking up space
   - Should be deleted to reduce confusion

4. **Missing Routes**
   - `ExportScreen` exists but has no route
   - `RemindersScreen` exists but has no route
   - Should either add routes or delete files

5. **Inconsistent Navigation**
   - `NotificationDebugScreen` uses old `Navigator.push`
   - Should use GoRouter for consistency

### 🟢 Minor Issues

6. **OnboardingScreen** (old) still exists
   - Replaced by EnhancedOnboardingScreen
   - Safe to delete

---

## 📊 STATISTICS

### Active Screens: 17
- SplashScreen ✅
- EnhancedOnboardingScreen ✅
- HomeScreen ✅
- MedicationsListScreen ✅
- MedicationDetailScreen ✅
- MedicationEditScreen ✅
- AddMedicationScreen ✅
- AnalyticsDashboardScreen ✅
- HistoryScreen ✅
- StockOverviewScreen ✅
- ChatbotScreen ✅
- ReportsScreen ✅
- InsightsScreen ✅
- SettingsScreen ✅
- DiagnosticsScreen ✅
- NotificationDebugScreen ⚠️ (via Navigator.push)
- Step1TypeInfo, Step2Schedule, Step3Stock (used by AddMedicationScreen) ✅

### Dead/Unreachable: 9
- AddMedicationWizardScreen ❌
- Step1MedicineTypeScreen ❌
- Step2MedicineNameScreen ❌
- Step3DosageScheduleScreen ❌
- Step4StockRefillScreen ❌
- RemindersScreen ❌
- ExportScreen ❌
- OnboardingScreen (old) ❌
- MediBotChatScreen (stub) ❌

---

## ✅ RECOMMENDED ACTIONS

### Priority 1: Fix Critical Route Mismatch
```dart
// In app_router.dart, fix the route-to-screen mapping:
GoRoute(
  path: '/history',
  name: 'history',
  builder: (context, state) => const MainScaffold(initialIndex: 3), // Fix: was 2
),
GoRoute(
  path: '/stock',
  name: 'stock',
  builder: (context, state) => const MainScaffold(initialIndex: 4), // Fix: was 3
),
GoRoute(
  path: '/chatbot',
  name: 'chatbot',
  builder: (context, state) => const MainScaffold(initialIndex: 5), // Fix: was 4
),
```

### Priority 2: Clean Up Dead Code
Delete these files:
- `lib/features/add_medication/screens/add_medication_wizard_screen.dart`
- `lib/features/add_medication/screens/step1_medicine_type_screen.dart`
- `lib/features/add_medication/screens/step2_medicine_name_screen.dart`
- `lib/features/add_medication/screens/step3_dosage_schedule_screen.dart`
- `lib/features/add_medication/screens/step4_stock_refill_screen.dart`
- `lib/features/onboarding/screens/onboarding_screen.dart`

### Priority 3: Handle Duplicate Chatbots
Option A: Delete `MediBotChatScreen` and its route (recommended)
Option B: Implement `MediBotChatScreen` with different purpose (e.g., medical info vs app help)

### Priority 4: Integrate or Remove Orphaned Screens
- `ExportScreen`: Add route or integrate into ReportsScreen
- `RemindersScreen`: Add route or delete (HistoryScreen covers this)

### Priority 5: Migrate NotificationDebugScreen to GoRouter
Convert from `Navigator.push` to `context.push('/diagnostics/notifications')`

---

## 🗺️ VISUAL NAVIGATION FLOW

```
App Launch
    ↓
SplashScreen (/splash)
    ↓
    ├─→ First Launch → EnhancedOnboardingScreen (/onboarding)
    └─→ Returning User → MainScaffold (/)
                            ↓
        ┌───────────────────────────────────────┐
        │     Bottom Navigation (6 tabs)        │
        ├───────────────────────────────────────┤
        │ 0: Home                               │
        │ 1: Medications → Detail → Edit        │
        │ 2: Analytics                          │
        │ 3: History                            │
        │ 4: Stock                              │
        │ 5: AI Chat                            │
        └───────────────────────────────────────┘
                            ↓
        Floating Action Button (+) → AddMedicationScreen
                            ↓
        App Bar Settings Icon → SettingsScreen
                                    ↓
                    ├─→ Debug Notifications → NotificationDebugScreen
                    ├─→ Diagnostics → DiagnosticsScreen
                    └─→ Export Data → (ExportScreen - NO ROUTE!)

Additional Routes:
- /reports → ReportsScreen
- /insights → InsightsScreen
- /analytics → AnalyticsDashboardScreen (duplicate access)
- /medibot → MediBotChatScreen (STUB - empty!)
```

---

## 📝 NOTES

1. **Bottom Navigation** shows 6 tabs, but routes only define direct access to 5
2. **MainScaffold** acts as a container, routes pass initialIndex
3. **GoRouter** is used correctly for most navigation
4. **Old Navigator.push** still used in one place (NotificationDebugScreen)
5. **No deep linking** appears to be configured yet
6. **No authentication** routes (app appears to be local-only)

---

Generated: 2025-01-11
Last Updated: Smart Snooze feature implementation
