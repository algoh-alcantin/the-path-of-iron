import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../services/powerlifting_program_service.dart';
import '../models/user_profile.dart';
import '../repositories/hive_database.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final PowerliftingProgramService _powerliftingProgramService = PowerliftingProgramService();
  bool _isLoading = true;
  bool _hasActiveProgram = false;
  UserProfile? _userProfile;
  int _currentWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      final hasProgram = await _powerliftingProgramService.isProgramActive();
      
      if (hasProgram) {
        final userProfileBox = HiveDatabase.userProfileBox;
        final userProfile = userProfileBox.get('current_user');
        final currentWeek = await _powerliftingProgramService.getCurrentWeek();
        
        if (mounted) {
          setState(() {
            _hasActiveProgram = hasProgram;
            _userProfile = userProfile;
            _currentWeek = currentWeek;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasActiveProgram = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasActiveProgram = false;
          _isLoading = false;
        });
      }
    }
  }

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
        actions: [
          if (_hasActiveProgram)
            IconButton(
              icon: const Icon(Icons.refresh, color: SamuraiColors.goldenKoi),
              onPressed: _loadProgressData,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SamuraiColors.goldenKoi))
          : _hasActiveProgram && _userProfile != null
              ? _buildProgressDashboard()
              : _buildNoActiveProgram(),
    );
  }

  Widget _buildNoActiveProgram() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
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
              'PATH AWAITS',
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 24,
                color: SamuraiColors.goldenKoi,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Begin your strength journey to track your progress up the mountain of gains.',
              style: SamuraiTextStyles.brushStroke(
                color: SamuraiColors.ashWhite,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Start a program to unlock detailed progress tracking.',
              style: SamuraiTextStyles.ancientWisdom(
                color: SamuraiColors.sakuraPink,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgramOverview(),
          const SizedBox(height: 20),
          _buildProgressStats(),
          const SizedBox(height: 20),
          _buildStrengthProgress(),
          const SizedBox(height: 20),
          _buildWeeklyProgress(),
          const SizedBox(height: 20),
          _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildProgramOverview() {
    final profile = _userProfile!;
    final totalWeeks = 18;
    final progressPercentage = (_currentWeek / totalWeeks).clamp(0.0, 1.0);
    final daysInProgram = DateTime.now().difference(profile.programStartDate).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SamuraiIcons.katana, color: SamuraiColors.sanguineRed, size: 24),
              const SizedBox(width: 12),
              Text(
                'Hip-Aware Powerlifting Journey',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.sanguineRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewStat('Week', '$_currentWeek/18'),
              _buildOverviewStat('Days', '$daysInProgram'),
              _buildOverviewStat('Progress', '${(progressPercentage * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Program Progress',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: SamuraiColors.ironGray.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progressPercentage < 0.33 
                  ? SamuraiColors.honorableGreen
                  : progressPercentage < 0.66 
                      ? SamuraiColors.goldenKoi
                      : SamuraiColors.sanguineRed,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            _getPhaseDescription(_currentWeek),
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.sakuraPink,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: SamuraiTextStyles.katanaSharp(
            color: SamuraiColors.goldenKoi,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: SamuraiTextStyles.ancientWisdom(
            color: SamuraiColors.ashWhite,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStats() {
    final profile = _userProfile!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: SamuraiColors.goldenKoi, size: 24),
              const SizedBox(width: 12),
              Text(
                'Strength Progression',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildLiftProgress('SQUAT', profile.currentMaxes['squat'] ?? 0, profile.targetMaxes['squat'] ?? 0, SamuraiColors.sanguineRed)),
              const SizedBox(width: 16),
              Expanded(child: _buildLiftProgress('BENCH', profile.currentMaxes['inclineBench'] ?? 0, profile.targetMaxes['inclineBench'] ?? 0, SamuraiColors.goldenKoi)),
              const SizedBox(width: 16),
              Expanded(child: _buildLiftProgress('DEADLIFT', profile.currentMaxes['deadlift'] ?? 0, profile.targetMaxes['deadlift'] ?? 0, SamuraiColors.contemplativeBlue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiftProgress(String lift, int current, int target, Color color) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final gain = target - current;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            lift,
            style: SamuraiTextStyles.brushStroke(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${current}kg',
            style: SamuraiTextStyles.katanaSharp(
              color: SamuraiColors.ashWhite,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: SamuraiColors.ironGray.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            '+${gain}kg goal',
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.sakuraPink,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SamuraiIcons.meditation, color: SamuraiColors.contemplativeBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Weekly Focus',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.contemplativeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFocusItem('Monday', 'Squat Focus + Hip Activation', SamuraiColors.sanguineRed),
          _buildFocusItem('Tuesday', 'Incline Bench Focus + Upper Back', SamuraiColors.goldenKoi),
          _buildFocusItem('Wednesday', 'Deadlift Focus + Unilateral Work', SamuraiColors.contemplativeBlue),
          _buildFocusItem('Thursday', 'Volume Upper + Correctives', SamuraiColors.honorableGreen),
          _buildFocusItem('Friday', 'Volume Lower + Hip Stability', SamuraiColors.sakuraPink),
        ],
      ),
    );
  }

  Widget _buildFocusItem(String day, String focus, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            day,
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              focus,
              style: SamuraiTextStyles.ancientWisdom(
                color: SamuraiColors.sakuraPink,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: SamuraiColors.honorableGreen, size: 24),
              const SizedBox(width: 12),
              Text(
                'Training Blocks',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.honorableGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBlockProgress('Accumulation', 1, 6, SamuraiColors.honorableGreen),
          const SizedBox(height: 8),
          _buildBlockProgress('Intensification', 7, 12, SamuraiColors.goldenKoi),
          const SizedBox(height: 8),
          _buildBlockProgress('Peaking', 13, 18, SamuraiColors.sanguineRed),
        ],
      ),
    );
  }

  Widget _buildBlockProgress(String blockName, int startWeek, int endWeek, Color color) {
    final isCurrentBlock = _currentWeek >= startWeek && _currentWeek <= endWeek;
    final blockProgress = isCurrentBlock 
        ? ((_currentWeek - startWeek + 1) / (endWeek - startWeek + 1)).clamp(0.0, 1.0)
        : _currentWeek > endWeek ? 1.0 : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentBlock 
            ? color.withValues(alpha: 0.2)
            : SamuraiColors.ironGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentBlock 
              ? color 
              : SamuraiColors.ironGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                blockName,
                style: SamuraiTextStyles.brushStroke(
                  color: isCurrentBlock ? color : SamuraiColors.ashWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Weeks $startWeek-$endWeek',
                style: SamuraiTextStyles.ancientWisdom(
                  color: SamuraiColors.sakuraPink,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: blockProgress,
            backgroundColor: SamuraiColors.ironGray.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          if (isCurrentBlock)
            Text(
              'Current Block - ${(blockProgress * 100).round()}% Complete',
              style: SamuraiTextStyles.ancientWisdom(
                color: color,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SamuraiIcons.meditation, color: SamuraiColors.sakuraPink, size: 24),
              const SizedBox(width: 12),
              Text(
                'Path Milestones',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.sakuraPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAchievementBadge('First Steps', 'Begin your journey', true, SamuraiColors.honorableGreen),
          const SizedBox(height: 8),
          _buildAchievementBadge('Max Testing', 'Complete strength assessment', _userProfile!.currentMaxes.values.any((max) => max > 0), SamuraiColors.goldenKoi),
          const SizedBox(height: 8),
          _buildAchievementBadge('Consistency', 'Complete first week', _currentWeek > 1, SamuraiColors.contemplativeBlue),
          const SizedBox(height: 8),
          _buildAchievementBadge('Dedication', 'Reach intensification block', _currentWeek >= 7, SamuraiColors.sanguineRed),
          const SizedBox(height: 8),
          _buildAchievementBadge('Mastery', 'Complete the full program', _currentWeek > 18, SamuraiColors.sakuraPink),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, String description, bool isEarned, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEarned 
            ? color.withValues(alpha: 0.2)
            : SamuraiColors.ironGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEarned 
              ? color 
              : SamuraiColors.ironGray.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEarned ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isEarned ? color : SamuraiColors.ironGray,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SamuraiTextStyles.brushStroke(
                    color: isEarned ? color : SamuraiColors.ashWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: SamuraiTextStyles.ancientWisdom(
                    color: SamuraiColors.sakuraPink,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseDescription(int week) {
    if (week <= 6) return 'Accumulation Phase - Building volume and work capacity';
    if (week <= 12) return 'Intensification Phase - Increasing intensity and strength';
    if (week <= 18) return 'Peaking Phase - Maximizing strength and preparing for PRs';
    return 'Program Complete - Time to test your new maxes!';
  }
}