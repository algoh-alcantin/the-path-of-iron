import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamuraiColors.midnightBlack,
      appBar: AppBar(
        title: Text(
          'PATH OF GROWTH',
          style: SamuraiTextStyles.katanaSharp(fontSize: 20),
        ),
        backgroundColor: SamuraiColors.midnightBlack,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: SamuraiDecorations.forgeContainer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                SamuraiIcons.mountainPath,
                color: SamuraiColors.goldenKoi,
                size: 64,
              ),
              const SizedBox(height: 20),
              Text(
                'MOUNTAIN OF PROGRESS',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 24,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Track your journey up the mountain of strength. Every step forward is progress.',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Coming Soon: Strength curves, volume tracking, and achievement badges.',
                style: SamuraiTextStyles.ancientWisdom(
                  color: SamuraiColors.sakuraPink,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}