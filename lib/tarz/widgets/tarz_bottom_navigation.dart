import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';

class TarzBottomNavigation extends StatelessWidget {
  const TarzBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 68,
      selectedIndex: currentIndex,
      onDestinationSelected: onChanged,
      backgroundColor: TarzColors.surface,
      indicatorColor: TarzColors.ink.withValues(alpha: 0.08),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Ana səhifə',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Kateqoriya',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border_rounded),
          selectedIcon: Icon(Icons.favorite_rounded),
          label: 'Seçilmiş',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
