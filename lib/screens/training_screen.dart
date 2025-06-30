import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../services/program_service.dart';
import '../services/powerlifting_program_service.dart';
import '../repositories/training_max_repository.dart';
import '../models/training_max.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../repositories/hive_database.dart';
import 'max_testing_screen.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _programService = ProgramService();
  final _powerliftingProgramService = PowerliftingProgramService();
  final _trainingMaxRepository = TrainingMaxRepository();
  
  bool _hasActiveProgram = false;
  bool _isLoading = true;
  List<TrainingMax> _trainingMaxes = [];
  
  // Powerlifting program state
  bool _hasPowerliftingProgram = false;
  Workout? _currentWorkout;
  
  // Set logging state
  Map<String, List<SetLog>> _setLogs = {}; // exerciseIndex -> list of set logs
  Set<String> _hoveredSets = {}; // Track which sets are being hovered
  
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
      // Check for powerlifting program first
      final hasPowerliftingProgram = await _powerliftingProgramService.isProgramActive();
      final hasLegacyProgram = await _programService.hasActiveProgram();
      final hasProgram = hasPowerliftingProgram || hasLegacyProgram;
      
      final trainingMaxes = await _trainingMaxRepository.getAllTrainingMaxes();
      
      if (mounted) {
        setState(() {
          _hasActiveProgram = hasProgram;
          _hasPowerliftingProgram = hasPowerliftingProgram;
          _trainingMaxes = trainingMaxes.where((tm) => tm.isActive).toList();
          _isLoading = false;
        });
        
        if (_hasActiveProgram) {
          if (hasPowerliftingProgram) {
            _loadPowerliftingWorkout();
          } else {
            _generateWorkoutSets();
          }
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

  Future<void> _loadPowerliftingWorkout() async {
    try {
      final userProfileBox = HiveDatabase.userProfileBox;
      final userProfile = userProfileBox.get('current_user');
      
      if (userProfile != null) {
        final currentWeek = await _powerliftingProgramService.getCurrentWeek();
        final today = DateTime.now();
        final dayName = _getDayName(today.weekday);
        
        // Get today's workout - this will either be a regular workout or max testing protocol
        final todaysWorkout = await _powerliftingProgramService.getWorkout(currentWeek, dayName);
        
        if (todaysWorkout != null) {
          setState(() {
            _currentWorkout = todaysWorkout;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading powerlifting workout: $e');
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
    if (_hasPowerliftingProgram && _currentWorkout != null) {
      return _buildPowerliftingWorkout();
    } else {
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
            value: _workoutSets.isEmpty ? 0.0 : (_currentSetIndex / _workoutSets.length).clamp(0.0, 1.0),
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

  Widget _buildPowerliftingWorkout() {
    final workout = _currentWorkout!;
    
    // Check if this is the max testing protocol
    if (workout.id == 'max_testing_protocol') {
      return _buildMaxTestingProtocol(workout);
    } else {
      return _buildRegularPowerliftingWorkout(workout);
    }
  }

  Widget _buildMaxTestingProtocol(Workout workout) {
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
              color: SamuraiColors.sanguineRed,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              workout.workoutName,
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 24,
                color: SamuraiColors.sanguineRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Complete max testing to establish your training maxes',
              style: SamuraiTextStyles.ancientWisdom(
                color: SamuraiColors.sakuraPink,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...workout.keyFocusPoints.map((point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: SamuraiColors.goldenKoi, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startMaxTesting,
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
                      SamuraiIcons.katana,
                      color: SamuraiColors.ashWhite,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'BEGIN MAX TESTING',
                      style: SamuraiTextStyles.katanaSharp(
                        fontSize: 16,
                        color: SamuraiColors.ashWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularPowerliftingWorkout(Workout workout) {
    return Column(
      children: [
        _buildPowerliftingWorkoutHeader(workout),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workout.exercises.length,
            itemBuilder: (context, index) => _buildPowerliftingExerciseCard(workout.exercises[index], index),
          ),
        ),
        _buildPowerliftingWorkoutControls(),
      ],
    );
  }

  Widget _buildPowerliftingWorkoutHeader(Workout workout) {
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
                'Week ${workout.weekNumber} • ${workout.blockPhase}',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SamuraiColors.sanguineRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  workout.targetRPERange,
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.sanguineRed,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            workout.workoutName,
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 18,
              color: SamuraiColors.goldenKoi,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderStat('Duration', '${workout.estimatedDuration}min'),
              _buildHeaderStat('Exercises', '${workout.exercises.length}'),
              _buildHeaderStat('Focus', workout.dayName.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: SamuraiTextStyles.katanaSharp(
            color: SamuraiColors.goldenKoi,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: SamuraiTextStyles.ancientWisdom(
            color: SamuraiColors.ashWhite,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerliftingExerciseCard(Exercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getExerciseTypeColor(exercise.type).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getExerciseTypeColor(exercise.type),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: SamuraiTextStyles.katanaSharp(
                        color: SamuraiColors.ashWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: SamuraiTextStyles.katanaSharp(
                          color: SamuraiColors.ashWhite,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${exercise.sets} sets • ${exercise.reps} reps • ${exercise.weight}',
                        style: SamuraiTextStyles.ancientWisdom(
                          color: SamuraiColors.sakuraPink,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SamuraiColors.ironGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exercise.type.toUpperCase(),
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Exercise details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise.rpeTarget != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.speed, color: SamuraiColors.goldenKoi, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Target RPE: ${exercise.rpeTarget}',
                        style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (exercise.restPeriod != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.timer, color: SamuraiColors.contemplativeBlue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Rest: ${(exercise.restPeriod! / 60).ceil()} min',
                        style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (exercise.cues.isNotEmpty) ...[
                  Text(
                    'Movement Cues:',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.goldenKoi,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...exercise.cues.map((cue) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: SamuraiColors.sakuraPink)),
                        Expanded(
                          child: Text(
                            cue,
                            style: SamuraiTextStyles.ancientWisdom(
                              color: SamuraiColors.ashWhite,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                ],
                // Set tracking section
                _buildSetTrackingSection(exercise),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getExerciseTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'main':
        return SamuraiColors.sanguineRed;
      case 'accessory':
        return SamuraiColors.goldenKoi;
      case 'unilateral':
        return SamuraiColors.contemplativeBlue;
      case 'warmup':
        return SamuraiColors.honorableGreen;
      case 'corrective':
        return SamuraiColors.sakuraPink;
      default:
        return SamuraiColors.ironGray;
    }
  }

  Widget _buildSetTrackingSection(Exercise exercise) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Tracking:',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.goldenKoi,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Interactive set logging
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(exercise.sets, (setIndex) {
              final exerciseKey = '${_currentWorkout!.exercises.indexOf(exercise)}';
              final setLogs = _setLogs[exerciseKey] ?? [];
              final hasLog = setIndex < setLogs.length && setLogs[setIndex].isCompleted;
              final setKey = '$exerciseKey-$setIndex';
              final isHovered = _hoveredSets.contains(setKey);
              
              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredSets.add(setKey)),
                onExit: (_) => setState(() => _hoveredSets.remove(setKey)),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showSetLogDialog(exerciseKey, setIndex, exercise),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getSetBackgroundColor(hasLog, isHovered),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getSetBorderColor(hasLog, isHovered),
                        width: hasLog ? 2 : (isHovered ? 2 : 1),
                      ),
                      boxShadow: isHovered ? [
                        BoxShadow(
                          color: _getSetBorderColor(hasLog, isHovered).withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${setIndex + 1}',
                          style: SamuraiTextStyles.brushStroke(
                            color: _getSetTextColor(hasLog, isHovered),
                            fontSize: 12,
                            fontWeight: hasLog ? FontWeight.bold : (isHovered ? FontWeight.w600 : FontWeight.normal),
                          ),
                        ),
                        if (hasLog && setIndex < setLogs.length)
                          Text(
                            '${setLogs[setIndex].rpe}',
                            style: SamuraiTextStyles.ancientWisdom(
                              color: _getSetTextColor(hasLog, isHovered),
                              fontSize: 8,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap sets to log weight, reps, and RPE',
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.sakuraPink,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerliftingWorkoutControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.midnightBlack,
        border: Border(
          top: BorderSide(
            color: SamuraiColors.ironGray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Save as draft / exit
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: SamuraiColors.ironGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'SAVE DRAFT',
                style: SamuraiTextStyles.katanaSharp(
                  color: SamuraiColors.ashWhite,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Complete workout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.honorableGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'COMPLETE',
                style: SamuraiTextStyles.katanaSharp(
                  color: SamuraiColors.ashWhite,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startMaxTesting() {
    // Navigate to max testing screen
    // This should be the same max testing screen used in program setup
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaxTestingScreen(
          onMaxesCalculated: (maxes) async {
            // Capture context references before async operations
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            
            // Update training maxes and regenerate workouts
            await _powerliftingProgramService.updateTrainingMaxesAndRegenerateWorkouts(maxes);
            
            // Refresh the training screen
            _loadData();
            
            if (mounted) {
              navigator.pop();
              
              // Show success message
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Training maxes updated! Your program is now ready.',
                    style: SamuraiTextStyles.brushStroke(),
                  ),
                  backgroundColor: SamuraiColors.honorableGreen,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showSetLogDialog(String exerciseKey, int setIndex, Exercise exercise) {
    // Initialize set logs for this exercise if needed
    if (!_setLogs.containsKey(exerciseKey)) {
      _setLogs[exerciseKey] = List.generate(exercise.sets, (index) => SetLog());
    }
    
    final setLog = _setLogs[exerciseKey]![setIndex];
    final weightController = TextEditingController(text: setLog.weight?.toString() ?? '');
    final repsController = TextEditingController(text: setLog.reps?.toString() ?? '');
    double currentRpe = setLog.rpe ?? 7.0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: SamuraiColors.midnightBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SamuraiColors.goldenKoi),
          ),
          title: Text(
            'Log Set ${setIndex + 1}',
            style: SamuraiTextStyles.katanaSharp(
              color: SamuraiColors.goldenKoi,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.name,
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Weight input
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                style: SamuraiTextStyles.katanaSharp(color: SamuraiColors.ashWhite),
                decoration: InputDecoration(
                  labelText: 'Weight',
                  labelStyle: SamuraiTextStyles.brushStroke(color: SamuraiColors.goldenKoi),
                  hintText: 'Enter weight',
                  hintStyle: SamuraiTextStyles.ancientWisdom(color: SamuraiColors.ashWhite.withValues(alpha: 0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SamuraiColors.ironGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SamuraiColors.goldenKoi),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Reps input
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                style: SamuraiTextStyles.katanaSharp(color: SamuraiColors.ashWhite),
                decoration: InputDecoration(
                  labelText: 'Reps',
                  labelStyle: SamuraiTextStyles.brushStroke(color: SamuraiColors.goldenKoi),
                  hintText: 'Enter reps',
                  hintStyle: SamuraiTextStyles.ancientWisdom(color: SamuraiColors.ashWhite.withValues(alpha: 0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SamuraiColors.ironGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SamuraiColors.goldenKoi),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // RPE selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RPE: ${currentRpe.toStringAsFixed(1)}',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.goldenKoi,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: SamuraiColors.goldenKoi,
                      inactiveTrackColor: SamuraiColors.ironGray,
                      thumbColor: SamuraiColors.goldenKoi,
                      overlayColor: SamuraiColors.goldenKoi.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: currentRpe,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18, // 0.5 increments
                      onChanged: (value) {
                        setDialogState(() {
                          currentRpe = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    _getRpeDescription(currentRpe),
                    style: SamuraiTextStyles.ancientWisdom(
                      color: SamuraiColors.sakuraPink,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ironGray),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                final reps = int.tryParse(repsController.text);
                
                if (weight != null && reps != null) {
                  setState(() {
                    _setLogs[exerciseKey]![setIndex] = SetLog(
                      weight: weight,
                      reps: reps,
                      rpe: currentRpe,
                      isCompleted: true,
                    );
                  });
                  Navigator.of(context).pop();
                } else {
                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter valid weight and reps',
                        style: SamuraiTextStyles.brushStroke(),
                      ),
                      backgroundColor: SamuraiColors.sanguineRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.goldenKoi,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: SamuraiTextStyles.katanaSharp(
                  color: SamuraiColors.midnightBlack,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRpeDescription(double rpe) {
    if (rpe <= 2) return 'Very light effort';
    if (rpe <= 4) return 'Light effort';
    if (rpe <= 6) return 'Moderate effort';
    if (rpe <= 7) return 'Somewhat hard, 3+ reps left';
    if (rpe <= 8) return 'Hard, 2-3 reps left';
    if (rpe <= 9) return 'Very hard, 1-2 reps left';
    if (rpe <= 9.5) return 'Extremely hard, 1 rep left';
    return 'Maximum effort, no reps left';
  }

  Color _getSetBackgroundColor(bool hasLog, bool isHovered) {
    if (hasLog) {
      return isHovered 
          ? SamuraiColors.honorableGreen.withValues(alpha: 0.3)
          : SamuraiColors.honorableGreen.withValues(alpha: 0.2);
    } else {
      return isHovered 
          ? SamuraiColors.goldenKoi.withValues(alpha: 0.2)
          : SamuraiColors.ironGray.withValues(alpha: 0.3);
    }
  }

  Color _getSetBorderColor(bool hasLog, bool isHovered) {
    if (hasLog) {
      return isHovered 
          ? SamuraiColors.honorableGreen
          : SamuraiColors.honorableGreen;
    } else {
      return isHovered 
          ? SamuraiColors.goldenKoi
          : SamuraiColors.goldenKoi.withValues(alpha: 0.3);
    }
  }

  Color _getSetTextColor(bool hasLog, bool isHovered) {
    if (hasLog) {
      return SamuraiColors.honorableGreen;
    } else {
      return isHovered 
          ? SamuraiColors.goldenKoi
          : SamuraiColors.ashWhite;
    }
  }
}

class SetLog {
  double? weight;
  int? reps;
  double? rpe;
  bool isCompleted;
  
  SetLog({
    this.weight,
    this.reps,
    this.rpe,
    this.isCompleted = false,
  });
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