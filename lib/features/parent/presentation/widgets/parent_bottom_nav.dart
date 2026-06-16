import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

int parentBottomNavIndexForRoute(String route) {
  return switch (route) {
    '/parent-grades' => 1,
    '/parent-history' => 2,
    _ => 0,
  };
}

class ParentBottomNav extends StatelessWidget {
  const ParentBottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  void _onTap(BuildContext context, int index) {
    final route = switch (index) {
      1 => '/parent-grades',
      2 => '/parent-history',
      _ => '/parent-dashboard',
    };

    if (route == currentRoute) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: parentBottomNavIndexForRoute(currentRoute),
      onTap: (index) => _onTap(context, index),
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF006A63),
      unselectedItemColor: const Color(0xFF747780),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart_rounded),
          label: 'Nilai',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined),
          activeIcon: Icon(Icons.event_note_rounded),
          label: 'Riwayat',
        ),
      ],
    );
  }
}
