import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/navigation/main_scaffold.dart';
import 'package:med_assist/features/add_medication/screens/add_medication_screen.dart';
import 'package:med_assist/features/analytics/screens/analytics_dashboard_screen.dart';
import 'package:med_assist/features/diagnostics/screens/diagnostics_screen.dart';
import 'package:med_assist/features/insights/screens/insights_screen.dart';
import 'package:med_assist/features/medications/screens/medication_detail_screen.dart';
import 'package:med_assist/features/medications/screens/medication_edit_screen.dart';
import 'package:med_assist/features/onboarding/screens/enhanced_onboarding_screen.dart';
import 'package:med_assist/features/onboarding/screens/splash_screen.dart';
import 'package:med_assist/features/reports/screens/reports_screen.dart';
import 'package:med_assist/features/settings/screens/backup_restore_screen.dart';
import 'package:med_assist/features/settings/screens/notification_debug_screen.dart';
import 'package:med_assist/features/settings/screens/settings_screen.dart';

class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      // Onboarding Flow
      GoRoute(
        path: AppConstants.routeSplash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        name: 'onboarding',
        builder: (context, state) => const EnhancedOnboardingScreen(),
      ),

      // Main App with Bottom Navigation
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        builder: (context, state) => const MainScaffold(),
      ),

      // Medication Management
      GoRoute(
        path: '/medications',
        name: 'medications',
        builder: (context, state) => const MainScaffold(initialIndex: 1),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const MainScaffold(initialIndex: 3),
      ),
      GoRoute(
        path: '/stock',
        name: 'stock',
        builder: (context, state) => const MainScaffold(initialIndex: 4),
      ),
      GoRoute(
        path: '/chatbot',
        name: 'chatbot',
        builder: (context, state) => const MainScaffold(initialIndex: 5),
      ),
      GoRoute(
        path: '/medication/:id',
        name: 'medication-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MedicationDetailScreen(medicationId: id);
        },
      ),
      GoRoute(
        path: '/medication/:id/edit',
        name: 'medication-edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MedicationEditScreen(medicationId: id);
        },
      ),
      GoRoute(
        path: AppConstants.routeAddReminder,
        name: 'add-medication',
        builder: (context, state) => const AddMedicationScreen(),
      ),

      // Analytics
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),

      // Reports & Insights
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/insights',
        name: 'insights',
        builder: (context, state) => const InsightsScreen(),
      ),


      // Settings & Diagnostics
      GoRoute(
        path: AppConstants.routeSettings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/diagnostics',
        name: 'diagnostics',
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: '/diagnostics/notifications',
        name: 'notification-debug',
        builder: (context, state) => const NotificationDebugScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        name: 'backup-restore',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
