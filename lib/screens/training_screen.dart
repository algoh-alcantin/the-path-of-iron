import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamuraiColors.midnightBlack,
      appBar: AppBar(
        title: Text(
          'TRAINING FORGE',
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
                SamuraiIcons.katana,
                color: SamuraiColors.goldenKoi,
                size: 64,
              ),
              const SizedBox(height: 20),
              Text(
                'FORGE OF IRON',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 24,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your training session awaits. The path to strength is forged one rep at a time.',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Coming Soon: Active workout tracking, rest timers, and real-time guidance.',
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