import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../providers/theme_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    // Watch theme so this widget rebuilds when theme toggles
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: AppColors.background,
      // Key forces IndexedStack children to rebuild when theme changes
      body: IndexedStack(
        key: ValueKey(isDark),
        index: currentIndex,
        children: const [HomeScreen(), HistoryScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: _VoidNavBar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(bottomNavIndexProvider.notifier).state = i,
      ),
    );
  }
}

class _VoidNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _VoidNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: AppColors.background.withValues(alpha: 0.7),
        child: SafeArea(top: false, child: SizedBox(height: 64,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavIcon(icon: Icons.home_outlined, activeIcon: Icons.home, isSelected: currentIndex == 0, onTap: () => onTap(0)),
            _NavIcon(icon: Icons.download_for_offline_outlined, activeIcon: Icons.download_for_offline, isSelected: currentIndex == 1, onTap: () => onTap(1)),
            _NavIcon(icon: Icons.person_outline, activeIcon: Icons.person, isSelected: currentIndex == 2, onTap: () => onTap(2)),
          ]),
        )),
      ),
    ));
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.activeIcon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 64, height: 64, child: Center(
        child: AnimatedScale(scale: isSelected ? 1.15 : 1.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
          child: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.secondary : AppColors.sageMuted, size: 26)),
      )),
    );
  }
}
