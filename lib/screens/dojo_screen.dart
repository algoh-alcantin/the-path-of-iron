import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../widgets/training_max_scroll.dart';
import '../widgets/samurai_bottom_nav.dart';
import '../services/program_service.dart';
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
  bool _hasActiveProgram = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // For now, always show empty state until we create a program
    _hasActiveProgram = false;
    _isLoading = false;
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
        _checkProgramStatus(); // Refresh the dojo state
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
    // For now, always show empty state for new users
    return _buildEmptyDojoState();
  }
  
  Widget _buildEmptyDojoState() {
    return CustomScrollView(
      slivers: [
        _buildHeroSection(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(40),
                decoration: SamuraiDecorations.forgeContainer,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Container(
                        padding: const EdgeInsets.all(20),
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
                          size: 80,
                          color: SamuraiColors.goldenKoi,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'WELCOME TO THE DOJO',
                        style: SamuraiTextStyles.katanaSharp(
                          fontSize: 24,
                          color: SamuraiColors.goldenKoi,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your training ground awaits, but first you must forge your path.',
                        style: SamuraiTextStyles.brushStroke(
                          fontSize: 16,
                          color: SamuraiColors.ashWhite,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
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
                                fontSize: 14,
                                color: SamuraiColors.sakuraPink,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '- Lao Tzu',
                              style: SamuraiTextStyles.brushStroke(
                                fontSize: 12,
                                color: SamuraiColors.ashWhite.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'To begin your strength journey, you must first create your training program.',
                        style: SamuraiTextStyles.brushStroke(
                          fontSize: 14,
                          color: SamuraiColors.ashWhite.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _currentIndex = 3); // Navigate to Setup tab
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SamuraiColors.sanguineRed,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'FORGE YOUR PATH',
                                style: SamuraiTextStyles.katanaSharp(
                                  fontSize: 16,
                                  color: SamuraiColors.ashWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Set up your training maxes, choose your program, and begin your journey to strength mastery.',
                        style: SamuraiTextStyles.ancientWisdom(
                          fontSize: 12,
                          color: SamuraiColors.ashWhite.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              _buildQuickStats(),
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
      expandedHeight: 280,
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
                top: 100,
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