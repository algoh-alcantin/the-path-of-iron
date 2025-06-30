import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../models/training_max.dart';
import 'package:uuid/uuid.dart';

class MaxTestingScreen extends StatefulWidget {
  final Function(Map<String, double>) onMaxesCalculated;
  
  const MaxTestingScreen({super.key, required this.onMaxesCalculated});

  @override
  State<MaxTestingScreen> createState() => _MaxTestingScreenState();
}

class _MaxTestingScreenState extends State<MaxTestingScreen> {
  final _uuid = const Uuid();
  int _currentExerciseIndex = 0;
  int _currentPhase = 0; // 0: Warmup, 1: Working Sets, 2: Max Attempt, 3: Results
  
  final List<String> _exercises = ['Squat', 'Incline Bench Press', 'Deadlift'];
  final Map<String, double> _calculatedMaxes = {};
  final Map<String, List<TestSet>> _testResults = {};
  
  // Current test state
  double _currentWeight = 135.0;
  int _currentReps = 0;
  int _currentRPE = 0;
  bool _isWarmingUp = true;
  List<TestSet> _currentExerciseSets = [];
  
  // Warmup protocol
  int _warmupStep = 0;
  final List<WarmupSet> _warmupProtocol = [
    WarmupSet(percentage: 0.4, reps: 5, description: "Light warmup - focus on form"),
    WarmupSet(percentage: 0.6, reps: 3, description: "Moderate - feel the movement"),
    WarmupSet(percentage: 0.75, reps: 2, description: "Building intensity"),
    WarmupSet(percentage: 0.85, reps: 1, description: "Near working weight"),
  ];

  String get _currentExercise => _exercises[_currentExerciseIndex];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamuraiColors.midnightBlack,
      appBar: AppBar(
        title: Text(
          'MAX TESTING PROTOCOL',
          style: SamuraiTextStyles.katanaSharp(fontSize: 20),
        ),
        backgroundColor: SamuraiColors.midnightBlack,
        elevation: 0,
      ),
      body: _buildCurrentPhase(),
    );
  }
  
  Widget _buildCurrentPhase() {
    switch (_currentPhase) {
      case 0:
        return _buildWarmupPhase();
      case 1:
        return _buildWorkingPhase();
      case 2:
        return _buildMaxPhase();
      case 3:
        return _buildResultsPhase();
      default:
        return _buildWarmupPhase();
    }
  }
  
  Widget _buildWarmupPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProgressHeader(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: SamuraiDecorations.forgeContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(SamuraiIcons.forge, color: SamuraiColors.sanguineRed),
                    const SizedBox(width: 12),
                    Text(
                      'WARMUP PROTOCOL',
                      style: SamuraiTextStyles.katanaSharp(
                        fontSize: 18,
                        color: SamuraiColors.ashWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Exercise: $_currentExercise',
                  style: SamuraiTextStyles.katanaSharp(
                    fontSize: 20,
                    color: SamuraiColors.goldenKoi,
                  ),
                ),
                const SizedBox(height: 20),
                if (_warmupStep < _warmupProtocol.length) ...[
                  _buildWarmupStep(_warmupProtocol[_warmupStep]),
                ] else ...[
                  _buildWarmupComplete(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProtocolInstructions(),
        ],
      ),
    );
  }
  
  Widget _buildWarmupStep(WarmupSet warmupSet) {
    double estimatedWeight = _currentWeight * warmupSet.percentage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_warmupStep + 1} of ${_warmupProtocol.length}',
          style: SamuraiTextStyles.brushStroke(
            color: SamuraiColors.sakuraPink,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SamuraiColors.sanguineRed.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SamuraiColors.sanguineRed),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${estimatedWeight.round()} lbs × ${warmupSet.reps} reps',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 24,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                warmupSet.description,
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Estimated starting weight (adjust if needed):',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (_currentWeight > 45) _currentWeight -= 5;
              }),
              icon: const Icon(Icons.remove, color: SamuraiColors.sanguineRed),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SamuraiColors.ironGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentWeight.round()} lbs',
                  style: SamuraiTextStyles.katanaSharp(
                    fontSize: 18,
                    color: SamuraiColors.goldenKoi,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _currentWeight += 5),
              icon: const Icon(Icons.add, color: SamuraiColors.honorableGreen),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _warmupStep++;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SamuraiColors.sanguineRed,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'SET COMPLETED',
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 16,
                color: SamuraiColors.ashWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWarmupComplete() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SamuraiColors.honorableGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SamuraiColors.honorableGreen),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: SamuraiColors.honorableGreen,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Warmup Complete!',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.honorableGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to begin working sets',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPhase = 1; // Move to working phase
                _warmupStep = 0; // Reset for next exercise
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SamuraiColors.goldenKoi,
              foregroundColor: SamuraiColors.midnightBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'BEGIN WORKING SETS',
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWorkingPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProgressHeader(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: SamuraiDecorations.forgeContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(SamuraiIcons.katana, color: SamuraiColors.goldenKoi),
                    const SizedBox(width: 12),
                    Text(
                      'WORKING SETS',
                      style: SamuraiTextStyles.katanaSharp(
                        fontSize: 18,
                        color: SamuraiColors.ashWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Exercise: $_currentExercise',
                  style: SamuraiTextStyles.katanaSharp(
                    fontSize: 20,
                    color: SamuraiColors.goldenKoi,
                  ),
                ),
                const SizedBox(height: 20),
                _buildWorkingSetInput(),
                const SizedBox(height: 20),
                if (_currentExerciseSets.isNotEmpty) _buildPreviousSets(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildWorkingSetInstructions(),
        ],
      ),
    );
  }
  
  Widget _buildWorkingSetInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record your set:',
          style: SamuraiTextStyles.brushStroke(
            color: SamuraiColors.ashWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight (lbs)',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (_currentWeight > 45) _currentWeight -= 5;
                        }),
                        icon: const Icon(Icons.remove, color: SamuraiColors.sanguineRed),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SamuraiColors.ironGray.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_currentWeight.round()}',
                            style: SamuraiTextStyles.katanaSharp(
                              fontSize: 16,
                              color: SamuraiColors.goldenKoi,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _currentWeight += 5),
                        icon: const Icon(Icons.add, color: SamuraiColors.honorableGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reps',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (_currentReps > 0) _currentReps--;
                        }),
                        icon: const Icon(Icons.remove, color: SamuraiColors.sanguineRed),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SamuraiColors.ironGray.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_currentReps',
                            style: SamuraiTextStyles.katanaSharp(
                              fontSize: 16,
                              color: SamuraiColors.goldenKoi,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _currentReps++),
                        icon: const Icon(Icons.add, color: SamuraiColors.honorableGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'RPE (Rate of Perceived Exertion)',
          style: SamuraiTextStyles.brushStroke(
            color: SamuraiColors.ashWhite,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(11, (index) {
            return GestureDetector(
              onTap: () => setState(() => _currentRPE = index),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _currentRPE == index 
                      ? SamuraiColors.goldenKoi 
                      : SamuraiColors.ironGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _currentRPE == index 
                        ? SamuraiColors.goldenKoi 
                        : SamuraiColors.ironGray,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: SamuraiTextStyles.katanaSharp(
                      fontSize: 14,
                      color: _currentRPE == index 
                          ? SamuraiColors.midnightBlack 
                          : SamuraiColors.ashWhite,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _currentReps > 0 && _currentRPE > 0 ? _recordSet : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamuraiColors.sanguineRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'RECORD SET',
                  style: SamuraiTextStyles.katanaSharp(
                    fontSize: 16,
                    color: SamuraiColors.ashWhite,
                  ),
                ),
              ),
            ),
            if (_currentExerciseSets.isNotEmpty) ...[
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _completeExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamuraiColors.goldenKoi,
                  foregroundColor: SamuraiColors.midnightBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'DONE',
                  style: SamuraiTextStyles.katanaSharp(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
  
  Widget _buildPreviousSets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sets completed:',
          style: SamuraiTextStyles.brushStroke(
            color: SamuraiColors.ashWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...(_currentExerciseSets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SamuraiColors.honorableGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SamuraiColors.honorableGreen),
            ),
            child: Row(
              children: [
                Text(
                  'Set ${index + 1}:',
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.ashWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${set.weight.round()} lbs × ${set.reps} reps',
                  style: SamuraiTextStyles.katanaSharp(
                    color: SamuraiColors.goldenKoi,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRPEColor(set.rpe).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'RPE ${set.rpe}',
                    style: SamuraiTextStyles.brushStroke(
                      fontSize: 10,
                      color: _getRPEColor(set.rpe),
                    ),
                  ),
                ),
              ],
            ),
          );
        })),
      ],
    );
  }
  
  Color _getRPEColor(int rpe) {
    if (rpe <= 6) return SamuraiColors.honorableGreen;
    if (rpe <= 8) return SamuraiColors.goldenKoi;
    return SamuraiColors.sanguineRed;
  }
  
  void _recordSet() {
    setState(() {
      _currentExerciseSets.add(TestSet(
        weight: _currentWeight,
        reps: _currentReps,
        rpe: _currentRPE,
      ));
      
      // Suggest next weight based on RPE
      if (_currentRPE <= 7 && _currentReps >= 3) {
        _currentWeight += 10; // Add more weight if it was easy
      } else if (_currentRPE >= 9) {
        _currentWeight += 5; // Small increment if it was hard
      } else {
        _currentWeight += 5; // Standard increment
      }
      
      _currentReps = 0;
      _currentRPE = 0;
    });
  }
  
  void _completeExercise() {
    // Calculate estimated 1RM from best set
    TestSet bestSet = _currentExerciseSets.reduce((a, b) {
      double aEstimate = _estimate1RM(a.weight, a.reps, a.rpe);
      double bEstimate = _estimate1RM(b.weight, b.reps, b.rpe);
      return aEstimate > bEstimate ? a : b;
    });
    
    double estimated1RM = _estimate1RM(bestSet.weight, bestSet.reps, bestSet.rpe);
    _calculatedMaxes[_currentExercise] = estimated1RM;
    _testResults[_currentExercise] = List.from(_currentExerciseSets);
    
    setState(() {
      _currentExerciseIndex++;
      _currentExerciseSets.clear();
      _currentPhase = 0; // Back to warmup for next exercise
      _currentWeight = 135.0; // Reset weight
      
      if (_currentExerciseIndex >= _exercises.length) {
        _currentPhase = 3; // Move to results
      }
    });
  }
  
  double _estimate1RM(double weight, int reps, int rpe) {
    // Use RPE-based 1RM estimation
    // RPE 10 = 0% in reserve, RPE 9 = 1 rep in reserve, etc.
    double repsInReserve = (10 - rpe).toDouble();
    double totalReps = reps.toDouble() + repsInReserve;
    
    // Epley formula with RPE adjustment
    return weight * (1 + (totalReps / 30));
  }
  
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.sakuraPink,
                ),
              ),
              Text(
                _getPhaseText(),
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.goldenKoi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentExerciseIndex + (_currentPhase / 4)) / _exercises.length,
            backgroundColor: SamuraiColors.ironGray,
            valueColor: const AlwaysStoppedAnimation<Color>(SamuraiColors.goldenKoi),
          ),
        ],
      ),
    );
  }
  
  String _getPhaseText() {
    switch (_currentPhase) {
      case 0: return 'Warmup';
      case 1: return 'Working Sets';
      case 2: return 'Max Attempt';
      case 3: return 'Complete';
      default: return 'Testing';
    }
  }
  
  Widget _buildProtocolInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.info_outline, color: SamuraiColors.contemplativeBlue),
              const SizedBox(width: 8),
              Text(
                'Protocol Guidelines',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Start conservative with your estimated working weight\n'
            '• Rest 2-3 minutes between warmup sets\n'
            '• Focus on perfect form throughout\n'
            '• Stop if you feel unsafe or form breaks down',
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.ashWhite,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkingSetInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.goldenKoi.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SamuraiColors.goldenKoi),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SamuraiIcons.meditation, color: SamuraiColors.goldenKoi),
              const SizedBox(width: 8),
              Text(
                'Working Set Guidelines',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Work up in weight until you reach RPE 8-9\n'
            '• Record every set for accurate estimation\n'
            '• Rest 3-5 minutes between heavier sets\n'
            '• RPE 10 = maximum effort, RPE 8 = 2 reps left\n'
            '• Stop when you achieve a reliable heavy set',
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.ashWhite,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMaxPhase() {
    // This phase could be used for true 1RM attempts if desired
    return _buildWorkingPhase();
  }
  
  Widget _buildResultsPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: SamuraiDecorations.forgeContainer,
            child: Column(
              children: [
                const Icon(
                  SamuraiIcons.torii,
                  color: SamuraiColors.goldenKoi,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  'MAX TESTING COMPLETE!',
                  style: SamuraiTextStyles.katanaSharp(
                    fontSize: 24,
                    color: SamuraiColors.goldenKoi,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your estimated training maxes have been calculated based on your performance.',
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.ashWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._calculatedMaxes.entries.map((entry) => _buildMaxResult(entry.key, entry.value)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onMaxesCalculated(_calculatedMaxes),
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.sanguineRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'CONTINUE TO PROGRAM SETUP',
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
  
  Widget _buildMaxResult(String exercise, double estimatedMax) {
    double trainingMax = estimatedMax * 0.9; // Use 90% as training max
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise,
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 18,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated 1RM:',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${estimatedMax.round()} lbs',
                    style: SamuraiTextStyles.katanaSharp(
                      fontSize: 20,
                      color: SamuraiColors.sanguineRed,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Training Max (90%):',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${trainingMax.round()} lbs',
                    style: SamuraiTextStyles.katanaSharp(
                      fontSize: 20,
                      color: SamuraiColors.honorableGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_testResults[exercise] != null) ...[
            const SizedBox(height: 12),
            Text(
              'Best set: ${_getBestSet(exercise)}',
              style: SamuraiTextStyles.ancientWisdom(
                color: SamuraiColors.sakuraPink,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _getBestSet(String exercise) {
    if (_testResults[exercise] == null || _testResults[exercise]!.isEmpty) {
      return 'No data';
    }
    
    TestSet bestSet = _testResults[exercise]!.reduce((a, b) {
      double aEstimate = _estimate1RM(a.weight, a.reps, a.rpe);
      double bEstimate = _estimate1RM(b.weight, b.reps, b.rpe);
      return aEstimate > bEstimate ? a : b;
    });
    
    return '${bestSet.weight.round()} lbs × ${bestSet.reps} @ RPE ${bestSet.rpe}';
  }
}

class TestSet {
  final double weight;
  final int reps;
  final int rpe;
  
  TestSet({required this.weight, required this.reps, required this.rpe});
}

class WarmupSet {
  final double percentage;
  final int reps;
  final String description;
  
  WarmupSet({required this.percentage, required this.reps, required this.description});
}