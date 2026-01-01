import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:swift_wallet_mobile/features/auth/auth_notifiers.dart';
import 'package:swift_wallet_mobile/features/dashboard/screens/home_tab.dart'; // New file
// import 'package:swift_wallet_mobile/features/dashboard/screens/statistics_tab.dart'; // To be created
// import 'package:swift_wallet_mobile/features/dashboard/screens/notifications_tab.dart'; // To be created
// import 'package:swift_wallet_mobile/features/dashboard/screens/profile_tab.dart'; // To be created

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen> {
  // state for the currently selected tab
  int _currentIdx = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    Placeholder(
      child: Center(child: Text('Statistics Tab')),
    ), // Placeholder
    Placeholder(
      child: Center(child: Text('Notifications Tab')),
    ), // Placeholder
    Placeholder(
      child: Center(child: Text('Profile Tab')),
    ), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIdx,
        children: _tabs,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIdx,
        onTap: (int index) {
          setState(() {
            _currentIdx = index;
          });
        }, // ontap
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey,
        showSelectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications_rounded),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/send');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Central Action: Scan/Transfer',
              ),
            ),
          );
        },
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.swap_horiz_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }
}
