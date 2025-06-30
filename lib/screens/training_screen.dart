import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../services/program_service.dart';
import '../repositories/training_max_repository.dart';
import '../models/training_max.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _programService = ProgramService();
  final _trainingMaxRepository = TrainingMaxRepository();
  
  bool _hasActiveProgram = false;
  bool _isLoading = true;
  List<TrainingMax> _trainingMaxes = [];
  
  // Current workout state
  final int _currentWeek = 3;
  final int _currentDay = 2;
  List<WorkoutSet> _workoutSets = [];
  int _currentSetIndex = 0;
  bool _isRestTimerActive = false;
  int _restTimeRemaining = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final hasProgram = await _programService.hasActiveProgram();
      final trainingMaxes = await _trainingMaxRepository.getAllTrainingMaxes();
      
      if (mounted) {
        setState(() {
          _hasActiveProgram = hasProgram;
          _trainingMaxes = trainingMaxes.where((tm) => tm.isActive).toList();
          _isLoading = false;
        });
        
        if (_hasActiveProgram) {
          _generateWorkoutSets();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasActiveProgram = false;
        });
      }
    }
  }
  
  void _generateWorkoutSets() {
    // Generate sets based on GZCL UHF program structure
    final benchTM = _trainingMaxes.firstWhere(
      (tm) => tm.exercise == 'Bench Press', 
      orElse: () => TrainingMax(id: '', exercise: 'Bench Press', weight: 225, lastTested: DateTime.now()),
    );
    
    setState(() {
      _workoutSets = [
        // T1 - Main lift (Bench Press)
        WorkoutSet(exercise: 'Bench Press', weight: (benchTM.weight * 0.85).round(), reps: 8, setType: 'T1', isCompleted: false),
        WorkoutSet(exercise: 'Bench Press', weight: (benchTM.weight * 0.90).round(), reps: 6, setType: 'T1', isCompleted: false),
        WorkoutSet(exercise: 'Bench Press', weight: (benchTM.weight * 0.95).round(), reps: 4, setType: 'T1', isCompleted: false),
        WorkoutSet(exercise: 'Bench Press', weight: (benchTM.weight * 1.00).round(), reps: 2, setType: 'T1', isCompleted: false),
        WorkoutSet(exercise: 'Bench Press', weight: (benchTM.weight * 1.05).round(), reps: 1, setType: 'T1 AMRAP', isCompleted: false),
        
        // T2 - Secondary lift (Front Squat)
        WorkoutSet(exercise: 'Front Squat', weight: (benchTM.weight * 0.65).round(), reps: 10, setType: 'T2', isCompleted: false),
        WorkoutSet(exercise: 'Front Squat', weight: (benchTM.weight * 0.65).round(), reps: 10, setType: 'T2', isCompleted: false),
        WorkoutSet(exercise: 'Front Squat', weight: (benchTM.weight * 0.65).round(), reps: 10, setType: 'T2', isCompleted: false),
        
        // T3 - Accessories
        WorkoutSet(exercise: 'Dumbbell Press', weight: 45, reps: 15, setType: 'T3', isCompleted: false),
        WorkoutSet(exercise: 'Dumbbell Press', weight: 45, reps: 15, setType: 'T3', isCompleted: false),
        WorkoutSet(exercise: 'Tricep Dips', weight: 0, reps: 15, setType: 'T3', isCompleted: false),
        WorkoutSet(exercise: 'Tricep Dips', weight: 0, reps: 15, setType: 'T3', isCompleted: false),
      ];
    });
  }

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
        actions: [
          if (_hasActiveProgram)
            IconButton(
              icon: const Icon(SamuraiIcons.meditation, color: SamuraiColors.goldenKoi),
              onPressed: () {
                // Show workout summary
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SamuraiColors.goldenKoi))
          : _hasActiveProgram
              ? _buildActiveWorkout()
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
              SamuraiIcons.katana,
              color: SamuraiColors.goldenKoi,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'FORGE AWAITS',
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 24,
                color: SamuraiColors.goldenKoi,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No active training program found. Create your program first to begin forging your strength.',
              style: SamuraiTextStyles.brushStroke(
                color: SamuraiColors.ashWhite,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveWorkout() {
    return Column(
      children: [
        _buildWorkoutHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _workoutSets.length,
            itemBuilder: (context, index) => _buildSetCard(index),
          ),
        ),
        if (_isRestTimerActive) _buildRestTimer(),
        _buildWorkoutControls(),
      ],
    );
  }
  
  Widget _buildWorkoutHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week $_currentWeek • Day $_currentDay',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.sakuraPink,
                  fontSize: 14,
                ),
              ),
              Text(
                'Bench Press Focus',
                style: SamuraiTextStyles.katanaSharp(
                  color: SamuraiColors.goldenKoi,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentSetIndex / _workoutSets.length,
            backgroundColor: SamuraiColors.ironGray,
            valueColor: const AlwaysStoppedAnimation<Color>(SamuraiColors.goldenKoi),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSetCard(int index) {
    final set = _workoutSets[index];
    final isCurrentSet = index == _currentSetIndex;
    final isCompleted = set.isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentSet 
            ? SamuraiColors.sanguineRed.withValues(alpha: 0.2)
            : isCompleted 
                ? SamuraiColors.honorableGreen.withValues(alpha: 0.2)
                : SamuraiColors.ironGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentSet 
              ? SamuraiColors.sanguineRed
              : isCompleted 
                  ? SamuraiColors.honorableGreen
                  : SamuraiColors.goldenKoi.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSetTypeColor(set.setType).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              set.setType,
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 12,
                color: _getSetTypeColor(set.setType),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  set.exercise,
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.ashWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${set.weight} lbs × ${set.reps} reps',
                  style: SamuraiTextStyles.katanaSharp(
                    color: SamuraiColors.goldenKoi,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: SamuraiColors.honorableGreen,
              size: 24,
            )
          else if (isCurrentSet)
            ElevatedButton(
              onPressed: () => _completeSet(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.sanguineRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'COMPLETE',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getSetTypeColor(String setType) {
    switch (setType) {
      case 'T1':
      case 'T1 AMRAP':
        return SamuraiColors.sanguineRed;
      case 'T2':
        return SamuraiColors.goldenKoi;
      case 'T3':
        return SamuraiColors.contemplativeBlue;
      default:
        return SamuraiColors.ashWhite;
    }
  }
  
  Widget _buildRestTimer() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SamuraiColors.contemplativeBlue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rest Period',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${_restTimeRemaining}s',
            style: SamuraiTextStyles.katanaSharp(
              color: SamuraiColors.contemplativeBlue,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          if (_currentSetIndex > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () => _previousSet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamuraiColors.contemplativeBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'PREVIOUS',
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.ashWhite,
                  ),
                ),
              ),
            ),
          if (_currentSetIndex > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentSetIndex < _workoutSets.length - 1 
                  ? () => _nextSet()
                  : () => _finishWorkout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.sanguineRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentSetIndex < _workoutSets.length - 1 ? 'NEXT SET' : 'FINISH WORKOUT',
                style: SamuraiTextStyles.katanaSharp(
                  color: SamuraiColors.ashWhite,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _completeSet(int index) {
    setState(() {
      _workoutSets[index].isCompleted = true;
      if (index == _currentSetIndex && _currentSetIndex < _workoutSets.length - 1) {
        _currentSetIndex++;
        _startRestTimer();
      }
    });
  }
  
  void _startRestTimer() {
    setState(() {
      _isRestTimerActive = true;
      _restTimeRemaining = 180; // 3 minutes
    });
    
    // Simple timer simulation
    Future.delayed(const Duration(seconds: 180), () {
      if (mounted) {
        setState(() {
          _isRestTimerActive = false;
        });
      }
    });
  }
  
  void _nextSet() {
    if (_currentSetIndex < _workoutSets.length - 1) {
      setState(() {
        _currentSetIndex++;
      });
    }
  }
  
  void _previousSet() {
    if (_currentSetIndex > 0) {
      setState(() {
        _currentSetIndex--;
      });
    }
  }
  
  void _finishWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SamuraiColors.ironGray,
        title: Text(
          'Workout Complete!',
          style: SamuraiTextStyles.katanaSharp(color: SamuraiColors.goldenKoi),
        ),
        content: Text(
          'Congratulations! You have completed your training session.',
          style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: SamuraiColors.sanguineRed),
            child: Text(
              'HONOR ACHIEVED',
              style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutSet {
  final String exercise;
  final int weight;
  final int reps;
  final String setType;
  bool isCompleted;
  
  WorkoutSet({
    required this.exercise,
    required this.weight,
    required this.reps,
    required this.setType,
    required this.isCompleted,
  });
}