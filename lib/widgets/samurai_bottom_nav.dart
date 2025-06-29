import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';

class SamuraiBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SamuraiBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SamuraiDecorations.templeNavigation,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: SamuraiColors.goldenKoi,
        unselectedItemColor: SamuraiColors.ashWhite.withValues(alpha: 0.6),
        currentIndex: currentIndex,
        onTap: onTap,
        elevation: 0,
        selectedLabelStyle: SamuraiTextStyles.brushStroke(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: SamuraiTextStyles.brushStroke(
          fontSize: 10,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 0 
                    ? SamuraiColors.goldenKoi.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(SamuraiIcons.torii),
            ),
            label: 'DOJO',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 1 
                    ? SamuraiColors.goldenKoi.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(SamuraiIcons.katana),
            ),
            label: 'TRAIN',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 2 
                    ? SamuraiColors.goldenKoi.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(SamuraiIcons.mountainPath),
            ),
            label: 'PROGRESS',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 3 
                    ? SamuraiColors.goldenKoi.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(SamuraiIcons.scrollWisdom),
            ),
            label: 'SETUP',
          ),
        ],
      ),
    );
  }
}