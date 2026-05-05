import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Shell branches: 0=dashboard, 1=grades, 2=profile
  // Nav items:      0=Beranda,   1=Absensi(push), 2=Nilai, 3=Profil
  int get _navIndex {
    return switch (navigationShell.currentIndex) {
      0 => 0, // dashboard → Beranda
      1 => 2, // grades → Nilai
      2 => 3, // profile → Profil
      _ => 0,
    };
  }

  void _onTap(BuildContext context, int index) {
    if (index == 1) {
      // Absensi — full-screen push, not a shell branch
      context.push('/attendance');
      return;
    }
    // Map nav index to branch index: 0→0, 2→1, 3→2
    final branchIndex = index == 0 ? 0 : index - 1;
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => _onTap(context, i),
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
            icon: Icon(Icons.fingerprint_outlined),
            activeIcon: Icon(Icons.fingerprint_rounded),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Nilai',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
