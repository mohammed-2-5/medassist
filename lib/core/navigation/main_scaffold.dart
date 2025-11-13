import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/analytics/screens/analytics_dashboard_screen.dart';
import 'package:med_assist/features/chatbot/screens/chatbot_screen.dart';
import 'package:med_assist/features/history/screens/history_screen.dart';
import 'package:med_assist/features/home/screens/home_screen.dart';
import 'package:med_assist/features/medications/screens/medications_list_screen.dart';
import 'package:med_assist/features/stock/screens/stock_overview_screen.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Main scaffold with bottom navigation bar
/// Provides easy access to main app sections
class MainScaffold extends ConsumerStatefulWidget {

  const MainScaffold({
    this.initialIndex = 0,
    super.key,
  });
  final int initialIndex;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    MedicationsListScreen(),
    AnalyticsDashboardScreen(),
    HistoryScreen(),
    StockOverviewScreen(),
    ChatbotScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(context, theme, l10n),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        elevation: 8,
        backgroundColor: colorScheme.surface,
        destinations: _buildDestinations(l10n, colorScheme),
      ),
    );
  }

  List<NavigationDestination> _buildDestinations(AppLocalizations l10n, ColorScheme colorScheme) {
    // Get low stock and expiring medications count
    final lowStockFuture = ref.read(appDatabaseProvider).getLowStockMedications();
    final expiringFuture = ref.read(appDatabaseProvider).getExpiringMedications();

    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.home,
      ),
      NavigationDestination(
        icon: FutureBuilder(
          future: expiringFuture,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            if (count > 0) {
              return Badge(
                label: Text('$count'),
                backgroundColor: colorScheme.error,
                child: const Icon(Icons.medication_outlined),
              );
            }
            return const Icon(Icons.medication_outlined);
          },
        ),
        selectedIcon: FutureBuilder(
          future: expiringFuture,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            if (count > 0) {
              return Badge(
                label: Text('$count'),
                backgroundColor: colorScheme.error,
                child: const Icon(Icons.medication),
              );
            }
            return const Icon(Icons.medication);
          },
        ),
        label: l10n.medications,
      ),
      NavigationDestination(
        icon: const Icon(Icons.analytics_outlined),
        selectedIcon: const Icon(Icons.analytics),
        label: l10n.reports,
      ),
      NavigationDestination(
        icon: const Icon(Icons.history_outlined),
        selectedIcon: const Icon(Icons.history),
        label: l10n.reminders,
      ),
      NavigationDestination(
        icon: FutureBuilder(
          future: lowStockFuture,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            if (count > 0) {
              return Badge(
                label: Text('$count'),
                backgroundColor: Colors.orange,
                child: const Icon(Icons.inventory_outlined),
              );
            }
            return const Icon(Icons.inventory_outlined);
          },
        ),
        selectedIcon: FutureBuilder(
          future: lowStockFuture,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            if (count > 0) {
              return Badge(
                label: Text('$count'),
                backgroundColor: Colors.orange,
                child: const Icon(Icons.inventory),
              );
            }
            return const Icon(Icons.inventory);
          },
        ),
        label: 'Stock',
      ),
      const NavigationDestination(
        icon: Icon(Icons.smart_toy_outlined),
        selectedIcon: Icon(Icons.smart_toy),
        label: 'AI Chat',
      ),
    ];
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    // Different AppBar for Home screen
    if (_currentIndex == 0) {
      final today = DateTime.now();
      final dateFormat = DateFormat('EEEE, MMM d');

      return AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.today,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              dateFormat.format(today),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
            tooltip: l10n.searchMedications,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppConstants.routeSettings),
            tooltip: l10n.settings,
          ),
        ],
      );
    }

    // Generic AppBar for other screens
    final titles = [
      l10n.today,
      l10n.medications,
      l10n.reports,
      l10n.reminders,
      'Stock',
      'AI Chat',
    ];

    return AppBar(
      title: Text(titles[_currentIndex]),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppConstants.routeSettings),
          tooltip: l10n.settings,
        ),
      ],
    );
  }
}
