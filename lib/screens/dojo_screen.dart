import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../widgets/training_max_scroll.dart';
import '../widgets/samurai_bottom_nav.dart';
import '../services/program_service.dart';
import '../services/powerlifting_program_service.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../repositories/hive_database.dart';
import 'program_setup_screen.dart';
import 'training_screen.dart';
import 'progress_screen.dart';

class DojoScreen extends StatefulWidget {
  const DojoScreen({super.key});

  @override
  State<DojoScreen> createState() => _DojoScreenState();
}

class _DojoScreenState extends State<DojoScreen> {
  int _currentIndex = 0;
  final ProgramService _programService = ProgramService();
  final PowerliftingProgramService _powerliftingProgramService = PowerliftingProgramService();
  bool _hasActiveProgram = false;
  bool _isLoading = true;
  UserProfile? _userProfile;
  Workout? _todaysWorkout;
  
  @override
  void initState() {
    super.initState();
    _loadProgramData();
  }
  
  Future<void> _loadProgramData() async {
    try {
      // Check for powerlifting program first
      final bool hasPowerliftingProgram = await _powerliftingProgramService.isProgramActive();
      
      if (hasPowerliftingProgram) {
        // Load user profile
        final userProfileBox = HiveDatabase.userProfileBox;
        final userProfile = userProfileBox.get('current_user');
        
        if (userProfile != null) {
          final currentWeek = await _powerliftingProgramService.getCurrentWeek();
          final today = DateTime.now();
          final dayName = _getDayName(today.weekday);
          
          // Get today's workout
          final todaysWorkout = await _powerliftingProgramService.getWorkout(currentWeek, dayName);
          
          if (mounted) {
            setState(() {
              _hasActiveProgram = true;
              _userProfile = userProfile;
              _todaysWorkout = todaysWorkout;
              _isLoading = false;
            });
          }
          return;
        }
      }
      
      // Check for legacy program
      final hasLegacyProgram = await _programService.hasActiveProgram();
      
      if (mounted) {
        setState(() {
          _hasActiveProgram = hasLegacyProgram;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading program data: $e');
      if (mounted) {
        setState(() {
          _hasActiveProgram = false;
          _isLoading = false;
        });
      }
    }
  }
  
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }
  
  Future<void> _checkProgramStatus() async {
    try {
      final hasProgram = await _programService.hasActiveProgram();
      if (mounted) {
        setState(() {
          _hasActiveProgram = hasProgram;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking program status: $e');
      if (mounted) {
        setState(() {
          _hasActiveProgram = false;
          _isLoading = false;
        });
      }
    }
  }
  
  List<Widget> get _screens => [
    _buildDojoHome(),
    const TrainingScreen(),
    const ProgressScreen(),
    ProgramSetupScreen(
      onProgramCreated: () {
        _loadProgramData(); // Refresh the dojo state
        setState(() => _currentIndex = 0); // Go back to dojo
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamuraiColors.midnightBlack,
      body: _screens[_currentIndex],
      bottomNavigationBar: SamuraiBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildDojoHome() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: SamuraiColors.goldenKoi),
      );
    }
    
    if (!_hasActiveProgram) {
      return _buildEmptyDojoState();
    }
    
    if (_userProfile != null) {
      return _buildActivePowerliftingProgram();
    }
    
    // Legacy program state (original functionality)
    return _buildEmptyDojoState();
  }
  
  Widget _buildActivePowerliftingProgram() {
    return CustomScrollView(
      slivers: [
        _buildPowerliftingHeroSection(),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_todaysWorkout != null) _buildTodaysWorkoutCard(),
              const SizedBox(height: 16),
              _buildProgramProgressCard(),
              const SizedBox(height: 16),
              _buildWeaknessCard(),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPowerliftingHeroSection() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: SamuraiColors.midnightBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                SamuraiColors.contemplativeBlue,
                SamuraiColors.midnightBlack,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${_userProfile!.name}!',
                  style: SamuraiTextStyles.katanaSharp(
                    fontSize: 24,
                    color: SamuraiColors.goldenKoi,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Week ${_userProfile!.currentWeek} • ${_userProfile!.currentPhase}',
                  style: SamuraiTextStyles.brushStroke(
                    fontSize: 16,
                    color: SamuraiColors.ashWhite,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _userProfile!.programProgress,
                  backgroundColor: SamuraiColors.ironGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(SamuraiColors.goldenKoi),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_userProfile!.programProgress * 100).round()}% Complete',
                  style: SamuraiTextStyles.ancientWisdom(
                    fontSize: 12,
                    color: SamuraiColors.sakuraPink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTodaysWorkoutCard() {
    if (_todaysWorkout == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SamuraiIcons.katana, color: SamuraiColors.sanguineRed),
              const SizedBox(width: 12),
              Text(
                'TODAY\'S MISSION',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _todaysWorkout!.workoutName,
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 20,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target RPE: ${_todaysWorkout!.targetRPERange} • ${_todaysWorkout!.estimatedDuration} mins',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.sakuraPink,
            ),
          ),
          if (_todaysWorkout!.requiresHipActivation) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SamuraiColors.contemplativeBlue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.accessibility_new, 
                       color: SamuraiColors.contemplativeBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Hip activation required',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentIndex = 1), // Go to training
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.sanguineRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'BEGIN TRAINING',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 16,
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgramProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STRENGTH PROGRESS',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 16,
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat('Squat', 
                _userProfile!.currentMaxes['squat']!, 
                _userProfile!.targetMaxes['squat']!),
              _buildProgressStat('Incline Bench', 
                _userProfile!.currentMaxes['inclineBench']!, 
                _userProfile!.targetMaxes['inclineBench']!),
              _buildProgressStat('Deadlift', 
                _userProfile!.currentMaxes['deadlift']!, 
                _userProfile!.targetMaxes['deadlift']!),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressStat(String lift, int current, int target) {
    double progress = current / target;
    return Column(
      children: [
        Text(
          lift,
          style: SamuraiTextStyles.brushStroke(
            fontSize: 10,
            color: SamuraiColors.ashWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current',
          style: SamuraiTextStyles.katanaSharp(
            fontSize: 18,
            color: SamuraiColors.goldenKoi,
          ),
        ),
        Text(
          '/ $target lbs',
          style: SamuraiTextStyles.ancientWisdom(
            fontSize: 8,
            color: SamuraiColors.sakuraPink,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: SamuraiColors.ironGray,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? SamuraiColors.honorableGreen : SamuraiColors.goldenKoi,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeaknessCard() {
    if (!_userProfile!.hipIssues) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SamuraiColors.contemplativeBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.accessibility_new, color: SamuraiColors.contemplativeBlue),
              const SizedBox(width: 12),
              Text(
                'WEAKNESS FOCUS',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 16,
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Targeting ${_userProfile!.hipSide} side weakness',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All unilateral exercises prioritize your ${_userProfile!.hipSide} side with targeted correctives.',
            style: SamuraiTextStyles.ancientWisdom(
              fontSize: 12,
              color: SamuraiColors.sakuraPink,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyDojoState() {
    return CustomScrollView(
      slivers: [
        _buildHeroSection(),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(24),
                decoration: SamuraiDecorations.forgeContainer,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SamuraiColors.goldenKoi,
                          width: 3,
                        ),
                        color: SamuraiColors.goldenKoi.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        SamuraiIcons.torii,
                        size: 64,
                        color: SamuraiColors.goldenKoi,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'WELCOME TO THE DOJO',
                      style: SamuraiTextStyles.katanaSharp(
                        fontSize: 20,
                        color: SamuraiColors.goldenKoi,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your training ground awaits, but first you must forge your path.',
                      style: SamuraiTextStyles.brushStroke(
                        fontSize: 14,
                        color: SamuraiColors.ashWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SamuraiColors.midnightBlack.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SamuraiColors.sakuraPink.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '"A journey of a thousand miles begins with a single step."',
                            style: SamuraiTextStyles.ancientWisdom(
                              fontSize: 12,
                              color: SamuraiColors.sakuraPink,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '- Lao Tzu',
                            style: SamuraiTextStyles.brushStroke(
                              fontSize: 10,
                              color: SamuraiColors.ashWhite.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'To begin your strength journey, you must first create your training program.',
                      style: SamuraiTextStyles.brushStroke(
                        fontSize: 13,
                        color: SamuraiColors.ashWhite.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _currentIndex = 3); // Navigate to Setup tab
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SamuraiColors.sanguineRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              SamuraiIcons.forge,
                              color: SamuraiColors.ashWhite,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'FORGE YOUR PATH',
                              style: SamuraiTextStyles.katanaSharp(
                                fontSize: 14,
                                color: SamuraiColors.ashWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Set up your training maxes, choose your program, and begin your journey to strength mastery.',
                      style: SamuraiTextStyles.ancientWisdom(
                        fontSize: 11,
                        color: SamuraiColors.ashWhite.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildQuickStats(),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SamuraiColors.goldenKoi.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'What awaits you:',
            style: SamuraiTextStyles.brushStroke(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: SamuraiIcons.katana,
                label: 'Daily\nWorkouts',
                color: SamuraiColors.sanguineRed,
              ),
              _buildStatItem(
                icon: SamuraiIcons.mountainPath,
                label: 'Progress\nTracking',
                color: SamuraiColors.goldenKoi,
              ),
              _buildStatItem(
                icon: SamuraiIcons.meditation,
                label: 'Recovery\nMonitoring',
                color: SamuraiColors.contemplativeBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: SamuraiTextStyles.brushStroke(
            fontSize: 10,
            color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: true,
      backgroundColor: SamuraiColors.midnightBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                SamuraiColors.sanguineRed,
                SamuraiColors.midnightBlack,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          SamuraiColors.ironGray.withValues(alpha: 0.3),
                          SamuraiColors.midnightBlack.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                top: 80,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          SamuraiIcons.torii,
                          color: SamuraiColors.goldenKoi,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'DOJO',
                          style: SamuraiTextStyles.katanaSharp(
                            fontSize: 28,
                            color: SamuraiColors.goldenKoi,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'THE DOJO',
                      style: SamuraiTextStyles.brushStroke(
                        fontSize: 16,
                        color: SamuraiColors.ashWhite,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SamuraiColors.midnightBlack.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SamuraiColors.goldenKoi.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"The ultimate aim of martial arts is not having to use them"',
                            style: SamuraiTextStyles.ancientWisdom(
                              fontSize: 14,
                              color: SamuraiColors.sakuraPink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '- Miyamoto Musashi',
                            style: SamuraiTextStyles.brushStroke(
                              fontSize: 12,
                              color: SamuraiColors.ashWhite.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysMission() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: SamuraiDecorations.forgeContainer,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    SamuraiIcons.katana,
                    color: SamuraiColors.goldenKoi,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TODAY\'S MISSION',
                    style: SamuraiTextStyles.katanaSharp(
                      fontSize: 18,
                      color: SamuraiColors.ashWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week 3 • Day 2',
                          style: SamuraiTextStyles.brushStroke(
                            fontSize: 14,
                            color: SamuraiColors.sakuraPink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bench Press Focus',
                          style: SamuraiTextStyles.katanaSharp(
                            fontSize: 20,
                            color: SamuraiColors.goldenKoi,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'T1: Bench Press • T2: Front Squat • T3: Accessories',
                          style: SamuraiTextStyles.brushStroke(
                            fontSize: 12,
                            color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SamuraiColors.sanguineRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: SamuraiColors.sanguineRed,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      SamuraiIcons.forge,
                      color: SamuraiColors.sanguineRed,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to workout screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SamuraiColors.sanguineRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'BEGIN TRAINING',
                    style: SamuraiTextStyles.katanaSharp(
                      fontSize: 16,
                      color: SamuraiColors.ashWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingMaxes() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRAINING MAXES',
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 16,
                color: SamuraiColors.ashWhite,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TrainingMaxScroll(
                  lift: 'SQ',
                  weight: '315',
                  unit: 'lbs',
                  trend: TrainingMaxTrend.up,
                ),
                TrainingMaxScroll(
                  lift: 'BP',
                  weight: '275',
                  unit: 'lbs',
                  trend: TrainingMaxTrend.stable,
                ),
                TrainingMaxScroll(
                  lift: 'DL',
                  weight: '405',
                  unit: 'lbs',
                  trend: TrainingMaxTrend.up,
                ),
                TrainingMaxScroll(
                  lift: 'OHP',
                  weight: '185',
                  unit: 'lbs',
                  trend: TrainingMaxTrend.down,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT BATTLES',
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 16,
                color: SamuraiColors.ashWhite,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (index) => _buildActivityItem(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {
        'title': 'Bench Press Victory',
        'subtitle': '275 lbs x 8 reps (PR!)',
        'date': '2 hours ago',
        'icon': SamuraiIcons.katana,
        'color': SamuraiColors.honorableGreen,
      },
      {
        'title': 'Squat Session',
        'subtitle': '315 lbs x 5 reps',
        'date': 'Yesterday',
        'icon': SamuraiIcons.mountainPath,
        'color': SamuraiColors.goldenKoi,
      },
      {
        'title': 'Rest Day Meditation',
        'subtitle': 'Recovery and reflection',
        'date': '2 days ago',
        'icon': SamuraiIcons.meditation,
        'color': SamuraiColors.contemplativeBlue,
      },
    ];

    final activity = activities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity['color'] as Color,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: SamuraiTextStyles.brushStroke(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SamuraiColors.ashWhite,
                  ),
                ),
                Text(
                  activity['subtitle'] as String,
                  style: SamuraiTextStyles.brushStroke(
                    fontSize: 12,
                    color: SamuraiColors.ashWhite.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['date'] as String,
            style: SamuraiTextStyles.ancientWisdom(
              fontSize: 10,
              color: SamuraiColors.sakuraPink,
            ),
          ),
        ],
      ),
    );
  }
}