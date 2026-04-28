import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/navigation/main_scaffold.dart';
import 'package:med_assist/features/add_medication/screens/add_medication_screen.dart';
import 'package:med_assist/features/analytics/screens/analytics_dashboard_screen.dart';
import 'package:med_assist/features/diagnostics/screens/diagnostics_screen.dart';
import 'package:med_assist/features/history/screens/history_screen.dart';
import 'package:med_assist/features/insights/screens/insights_screen.dart';
import 'package:med_assist/features/medications/screens/medication_detail_screen.dart';
import 'package:med_assist/features/medications/screens/medication_edit_screen.dart';
import 'package:med_assist/features/onboarding/screens/enhanced_onboarding_screen.dart';
import 'package:med_assist/features/reports/screens/reports_screen.dart';
import 'package:med_assist/features/settings/screens/backup_restore_screen.dart';
import 'package:med_assist/features/settings/screens/notification_debug_screen.dart';
import 'package:med_assist/features/settings/screens/notification_settings_screen.dart';
import 'package:med_assist/features/settings/screens/settings_screen.dart';
import 'package:med_assist/features/splash/screens/splash_screen.dart';
import 'package:med_assist/features/shopping_list/screens/shopping_list_screen.dart';
import 'package:med_assist/features/stock/screens/stock_overview_screen.dart';

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
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/stock',
        name: 'stock',
        builder: (context, state) => const StockOverviewScreen(),
      ),
      GoRoute(
        path: AppConstants.routeShoppingList,
        name: 'shopping-list',
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        name: 'chatbot',
        builder: (context, state) => const MainScaffold(initialIndex: 3),
      ),
      GoRoute(
        path: '/medication/:id',
        name: 'medication-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomTransitionPage(
            key: state.pageKey,
            child: MedicationDetailScreen(medicationId: id),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final slide =
                      Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: SlideTransition(position: slide, child: child),
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/medication/:id/edit',
        name: 'medication-edit',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomTransitionPage(
            key: state.pageKey,
            child: MedicationEditScreen(medicationId: id),
            transitionDuration: const Duration(milliseconds: 280),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final slide =
                      Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: SlideTransition(position: slide, child: child),
                  );
                },
          );
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
      GoRoute(
        path: '/settings/notifications',
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
