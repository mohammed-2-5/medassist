import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/widgets/premium_bottom_navigation_bar.dart';
import 'package:med_assist/features/analytics/screens/analytics_dashboard_screen.dart';
import 'package:med_assist/features/chatbot/screens/chatbot_screen.dart';
import 'package:med_assist/features/home/screens/home_screen.dart';
import 'package:med_assist/features/medications/screens/medications_list_screen.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

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
    ChatbotScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticService.light();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PremiumBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
