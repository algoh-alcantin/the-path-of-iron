import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';

enum TrainingMaxTrend { up, down, stable }

class TrainingMaxScroll extends StatelessWidget {
  final String lift;
  final String weight;
  final String unit;
  final TrainingMaxTrend trend;

  const TrainingMaxScroll({
    super.key,
    required this.lift,
    required this.weight,
    required this.unit,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 100,
      decoration: SamuraiDecorations.scrollDecoration,
      child: Stack(
        children: [
          // Scroll content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                lift,
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 14,
                  color: SamuraiColors.sanguineRed,
                ),
              ),
              Text(
                weight,
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.midnightBlack,
                ),
              ),
              Text(
                unit,
                style: SamuraiTextStyles.brushStroke(
                  fontSize: 10,
                  color: SamuraiColors.ironGray,
                ),
              ),
            ],
          ),
          // Trend indicator
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getTrendColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _getTrendIcon(),
                size: 10,
                color: _getTrendColor(),
              ),
            ),
          ),
          // Hanging cord effect
          Positioned(
            top: 0,
            left: 35,
            child: Container(
              width: 2,
              height: 8,
              color: SamuraiColors.goldenKoi,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor() {
    switch (trend) {
      case TrainingMaxTrend.up:
        return SamuraiColors.honorableGreen;
      case TrainingMaxTrend.down:
        return SamuraiColors.shamefulRed;
      case TrainingMaxTrend.stable:
        return SamuraiColors.goldenKoi;
    }
  }

  IconData _getTrendIcon() {
    switch (trend) {
      case TrainingMaxTrend.up:
        return Icons.trending_up;
      case TrainingMaxTrend.down:
        return Icons.trending_down;
      case TrainingMaxTrend.stable:
        return Icons.trending_flat;
    }
  }
}