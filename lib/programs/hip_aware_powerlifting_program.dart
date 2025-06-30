import '../models/program.dart';
import '../models/phase.dart';
import '../models/progression_logic.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

/// Factory for creating the Hip-Aware Powerlifting Program
class HipAwarePowerliftingProgramFactory {
  
  static Program createProgram() {
    return Program(
      id: 'hip_aware_powerlifting_v1',
      name: 'Hip-Aware Powerlifting Program',
      description: 'An 18-week powerlifting program designed to address hip imbalances while building maximum strength in the squat, bench press, and deadlift.',
      type: ProgramType.powerlifting,
      phases: _createPhases(),
      metadata: _createMetadata(),
      progressionLogic: _createProgressionLogic(),
      requiredEquipment: [
        'Barbell',
        'Squat Rack',
        'Bench',
        'Plates',
        'Dumbbells',
        'Resistance Bands',
      ],
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: ProgramDuration(weeks: 18),
    );
  }

  static List<Phase> _createPhases() {
    return [
      _createAccumulationPhase(),
      _createIntensificationPhase(),
      _createPeakingPhase(),
    ];
  }

  static Phase _createAccumulationPhase() {
    return Phase(
      id: 'accumulation_phase',
      name: 'Accumulation',
      description: 'Building volume and work capacity while addressing hip imbalances',
      type: PhaseType.accumulation,
      durationWeeks: 6,
      workoutTemplates: _createWeeklyWorkouts('accumulation'),
      characteristics: PhaseCharacteristics(
        volumeMultiplier: 1.2,
        intensityMultiplier: 0.8,
        exerciseEmphasis: {
          'squat': 1.0,
          'incline_bench': 1.0,
          'deadlift': 1.0,
          'unilateral': 1.5, // Emphasis on unilateral work
          'corrective': 1.8, // High emphasis on correctives
        },
        primaryGoals: [
          'Build work capacity',
          'Address hip imbalances',
          'Establish movement patterns',
          'Increase training volume tolerance',
        ],
      ),
      sequenceNumber: 1,
    );
  }

  static Phase _createIntensificationPhase() {
    return Phase(
      id: 'intensification_phase',
      name: 'Intensification',
      description: 'Increasing intensity while maintaining hip stability',
      type: PhaseType.intensification,
      durationWeeks: 6,
      workoutTemplates: _createWeeklyWorkouts('intensification'),
      characteristics: PhaseCharacteristics(
        volumeMultiplier: 1.0,
        intensityMultiplier: 1.1,
        exerciseEmphasis: {
          'squat': 1.2,
          'incline_bench': 1.2,
          'deadlift': 1.2,
          'unilateral': 1.2,
          'corrective': 1.0,
        },
        primaryGoals: [
          'Increase training intensity',
          'Build strength',
          'Maintain hip stability',
          'Prepare for peak loads',
        ],
      ),
      sequenceNumber: 2,
    );
  }

  static Phase _createPeakingPhase() {
    return Phase(
      id: 'peaking_phase',
      name: 'Peaking',
      description: 'Maximizing strength for testing new PRs',
      type: PhaseType.peaking,
      durationWeeks: 6,
      workoutTemplates: _createWeeklyWorkouts('peaking'),
      characteristics: PhaseCharacteristics(
        volumeMultiplier: 0.7,
        intensityMultiplier: 1.3,
        exerciseEmphasis: {
          'squat': 1.5,
          'incline_bench': 1.5,
          'deadlift': 1.5,
          'unilateral': 0.8,
          'corrective': 0.6,
        },
        primaryGoals: [
          'Peak strength',
          'Taper volume',
          'Optimize for PRs',
          'Maintain movement quality',
        ],
      ),
      sequenceNumber: 3,
    );
  }

  static List<Workout> _createWeeklyWorkouts(String phase) {
    return [
      _createMondayWorkout(phase),
      _createTuesdayWorkout(phase),
      _createWednesdayWorkout(phase),
      _createThursdayWorkout(phase),
      _createFridayWorkout(phase),
    ];
  }

  static Workout _createMondayWorkout(String phase) {
    return Workout(
      id: 'monday_squat_focus',
      dayName: 'monday',
      workoutName: 'Squat Focus + Hip Activation',
      weekNumber: 1, // Will be updated by phase logic
      blockPhase: phase,
      exercises: [
        // Hip activation circuit
        Exercise(
          name: 'Hip Activation Circuit',
          sets: 1,
          reps: '1 round',
          weight: 'bodyweight',
          type: 'warmup',
          cues: [
            'Complete all exercises in sequence',
            'Focus on activation, not fatigue',
            'Hold each position for specified time',
          ],
          isUnilateral: false,
          muscleGroup: 'hips',
          restPeriod: 60,
          requiresHipActivation: true,
        ),
        
        // Main squat work
        Exercise(
          name: 'Back Squat',
          sets: _getSquatSets(phase),
          reps: _getSquatReps(phase),
          weight: _getSquatWeight(phase),
          type: 'main',
          cues: [
            'Maintain neutral spine throughout',
            'Drive knees out in line with toes',
            'Engage glutes at the top',
            'Control the descent',
          ],
          isUnilateral: false,
          muscleGroup: 'legs',
          equipment: 'barbell',
          restPeriod: 300,
          rpeTarget: _getSquatRPE(phase),
        ),

        // Accessory work
        Exercise(
          name: 'Bulgarian Split Squat',
          sets: 3,
          reps: '8 each',
          weight: 'dumbbell',
          type: 'unilateral',
          cues: [
            'Focus on the weaker side',
            'Keep torso upright',
            'Drive through front heel',
            'Control the descent',
          ],
          isUnilateral: true,
          muscleGroup: 'legs',
          equipment: 'dumbbell',
          restPeriod: 120,
          rpeTarget: '7-8',
        ),

        Exercise(
          name: 'Hip Abductor Strengthening',
          sets: 3,
          reps: '12 each',
          weight: 'band',
          type: 'corrective',
          cues: [
            'Maintain steady rhythm',
            'Feel the burn in hip abductors',
            'Keep hips level',
            'Focus on weaker side',
          ],
          isUnilateral: true,
          muscleGroup: 'hips',
          equipment: 'band',
          restPeriod: 90,
          rpeTarget: '6-7',
        ),
      ],
      requiresHipActivation: true,
      keyFocusPoints: [
        'Prioritize hip activation before main work',
        'Focus on squat technique and depth',
        'Address hip imbalances with unilateral work',
        'Maintain proper knee tracking',
      ],
      targetRPERange: _getWorkoutRPE(phase),
      estimatedDuration: _getWorkoutDuration(phase, 'main'),
    );
  }

  static Workout _createTuesdayWorkout(String phase) {
    return Workout(
      id: 'tuesday_bench_focus',
      dayName: 'tuesday',
      workoutName: 'Incline Bench Focus + Upper Back',
      weekNumber: 1,
      blockPhase: phase,
      exercises: [
        Exercise(
          name: 'Upper Body Warmup',
          sets: 1,
          reps: '1 round',
          weight: 'bodyweight',
          type: 'warmup',
          cues: [
            'Activate shoulders and upper back',
            'Prepare for pressing movements',
            'Focus on mobility and activation',
          ],
          isUnilateral: false,
          muscleGroup: 'upper',
          restPeriod: 60,
        ),

        Exercise(
          name: 'Incline Bench Press',
          sets: _getBenchSets(phase),
          reps: _getBenchReps(phase),
          weight: _getBenchWeight(phase),
          type: 'main',
          cues: [
            'Retract shoulder blades',
            'Drive through feet',
            'Control the descent',
            'Press to full extension',
          ],
          isUnilateral: false,
          muscleGroup: 'chest',
          equipment: 'barbell',
          restPeriod: 300,
          rpeTarget: _getBenchRPE(phase),
        ),

        Exercise(
          name: 'Barbell Rows',
          sets: 4,
          reps: '8-10',
          weight: '70% bench',
          type: 'accessory',
          cues: [
            'Pull to lower chest',
            'Squeeze shoulder blades',
            'Control the negative',
            'Keep core tight',
          ],
          isUnilateral: false,
          muscleGroup: 'back',
          equipment: 'barbell',
          restPeriod: 180,
          rpeTarget: '7-8',
        ),
      ],
      requiresHipActivation: false,
      keyFocusPoints: [
        'Focus on incline bench technique',
        'Build upper back strength',
        'Maintain shoulder health',
        'Balance pressing with pulling',
      ],
      targetRPERange: _getWorkoutRPE(phase),
      estimatedDuration: _getWorkoutDuration(phase, 'main'),
    );
  }

  static Workout _createWednesdayWorkout(String phase) {
    return Workout(
      id: 'wednesday_deadlift_focus',
      dayName: 'wednesday',
      workoutName: 'Deadlift Focus + Unilateral Work',
      weekNumber: 1,
      blockPhase: phase,
      exercises: [
        Exercise(
          name: 'Deadlift Warmup',
          sets: 1,
          reps: '1 round',
          weight: 'bodyweight',
          type: 'warmup',
          cues: [
            'Activate posterior chain',
            'Prepare hip hinge pattern',
            'Mobilize spine and hips',
          ],
          isUnilateral: false,
          muscleGroup: 'posterior',
          restPeriod: 90,
        ),

        Exercise(
          name: 'Conventional Deadlift',
          sets: _getDeadliftSets(phase),
          reps: _getDeadliftReps(phase),
          weight: _getDeadliftWeight(phase),
          type: 'main',
          cues: [
            'Hinge at hips first',
            'Keep bar close to body',
            'Drive through heels',
            'Finish with glutes',
          ],
          isUnilateral: false,
          muscleGroup: 'posterior',
          equipment: 'barbell',
          restPeriod: 300,
          rpeTarget: _getDeadliftRPE(phase),
        ),

        Exercise(
          name: 'Single Leg Romanian Deadlift',
          sets: 3,
          reps: '6 each',
          weight: 'dumbbell',
          type: 'unilateral',
          cues: [
            'Focus on hip hinge',
            'Maintain balance',
            'Feel stretch in hamstring',
            'Control the movement',
          ],
          isUnilateral: true,
          muscleGroup: 'posterior',
          equipment: 'dumbbell',
          restPeriod: 120,
          rpeTarget: '7-8',
        ),
      ],
      requiresHipActivation: true,
      keyFocusPoints: [
        'Perfect deadlift technique',
        'Strengthen posterior chain',
        'Address unilateral imbalances',
        'Maintain hip mobility',
      ],
      targetRPERange: _getWorkoutRPE(phase),
      estimatedDuration: _getWorkoutDuration(phase, 'main'),
    );
  }

  static Workout _createThursdayWorkout(String phase) {
    return Workout(
      id: 'thursday_volume_upper',
      dayName: 'thursday',
      workoutName: 'Volume Upper + Correctives',
      weekNumber: 1,
      blockPhase: phase,
      exercises: [
        Exercise(
          name: 'Dumbbell Bench Press',
          sets: 4,
          reps: '10-12',
          weight: 'dumbbell',
          type: 'accessory',
          cues: [
            'Full range of motion',
            'Control the dumbbells',
            'Squeeze at the top',
            'Feel the stretch at bottom',
          ],
          isUnilateral: false,
          muscleGroup: 'chest',
          equipment: 'dumbbell',
          restPeriod: 120,
          rpeTarget: '7-8',
        ),

        Exercise(
          name: 'Lat Pulldowns',
          sets: 4,
          reps: '10-12',
          weight: 'cable',
          type: 'accessory',
          cues: [
            'Pull to upper chest',
            'Squeeze shoulder blades',
            'Control the negative',
            'Keep chest up',
          ],
          isUnilateral: false,
          muscleGroup: 'back',
          equipment: 'cable',
          restPeriod: 120,
          rpeTarget: '7-8',
        ),
      ],
      requiresHipActivation: false,
      keyFocusPoints: [
        'Build volume in upper body',
        'Focus on corrective exercises',
        'Address muscle imbalances',
        'Maintain movement quality',
      ],
      targetRPERange: _getWorkoutRPE(phase),
      estimatedDuration: _getWorkoutDuration(phase, 'volume'),
    );
  }

  static Workout _createFridayWorkout(String phase) {
    return Workout(
      id: 'friday_volume_lower',
      dayName: 'friday',
      workoutName: 'Volume Lower + Hip Stability',
      weekNumber: 1,
      blockPhase: phase,
      exercises: [
        Exercise(
          name: 'Hip Stability Circuit',
          sets: 2,
          reps: '1 round',
          weight: 'bodyweight',
          type: 'corrective',
          cues: [
            'Focus on stability and control',
            'Maintain proper alignment',
            'Feel the activation in stabilizers',
          ],
          isUnilateral: true,
          muscleGroup: 'hips',
          restPeriod: 90,
          requiresHipActivation: true,
        ),

        Exercise(
          name: 'Goblet Squats',
          sets: 4,
          reps: '12-15',
          weight: 'dumbbell',
          type: 'accessory',
          cues: [
            'Hold dumbbell at chest',
            'Squat to full depth',
            'Drive knees out',
            'Pause at bottom',
          ],
          isUnilateral: false,
          muscleGroup: 'legs',
          equipment: 'dumbbell',
          restPeriod: 120,
          rpeTarget: '7-8',
        ),
      ],
      requiresHipActivation: true,
      keyFocusPoints: [
        'Build lower body volume',
        'Enhance hip stability',
        'Perfect movement patterns',
        'Prepare for next week',
      ],
      targetRPERange: _getWorkoutRPE(phase),
      estimatedDuration: _getWorkoutDuration(phase, 'volume'),
    );
  }

  // Phase-specific parameters
  static int _getSquatSets(String phase) {
    switch (phase) {
      case 'accumulation': return 5;
      case 'intensification': return 4;
      case 'peaking': return 3;
      default: return 4;
    }
  }

  static String _getSquatReps(String phase) {
    switch (phase) {
      case 'accumulation': return '5';
      case 'intensification': return '3-4';
      case 'peaking': return '1-2';
      default: return '5';
    }
  }

  static String _getSquatWeight(String phase) {
    switch (phase) {
      case 'accumulation': return '75-85%';
      case 'intensification': return '85-95%';
      case 'peaking': return '95-105%';
      default: return '80%';
    }
  }

  static String _getSquatRPE(String phase) {
    switch (phase) {
      case 'accumulation': return '7-8';
      case 'intensification': return '8-9';
      case 'peaking': return '9-10';
      default: return '8';
    }
  }

  static int _getBenchSets(String phase) {
    switch (phase) {
      case 'accumulation': return 4;
      case 'intensification': return 4;
      case 'peaking': return 3;
      default: return 4;
    }
  }

  static String _getBenchReps(String phase) {
    switch (phase) {
      case 'accumulation': return '6-8';
      case 'intensification': return '3-5';
      case 'peaking': return '1-3';
      default: return '6';
    }
  }

  static String _getBenchWeight(String phase) {
    switch (phase) {
      case 'accumulation': return '70-80%';
      case 'intensification': return '80-90%';
      case 'peaking': return '90-100%';
      default: return '75%';
    }
  }

  static String _getBenchRPE(String phase) {
    switch (phase) {
      case 'accumulation': return '7-8';
      case 'intensification': return '8-9';
      case 'peaking': return '9-10';
      default: return '8';
    }
  }

  static int _getDeadliftSets(String phase) {
    switch (phase) {
      case 'accumulation': return 4;
      case 'intensification': return 3;
      case 'peaking': return 2;
      default: return 3;
    }
  }

  static String _getDeadliftReps(String phase) {
    switch (phase) {
      case 'accumulation': return '3-5';
      case 'intensification': return '2-3';
      case 'peaking': return '1-2';
      default: return '3';
    }
  }

  static String _getDeadliftWeight(String phase) {
    switch (phase) {
      case 'accumulation': return '80-90%';
      case 'intensification': return '90-100%';
      case 'peaking': return '100-110%';
      default: return '85%';
    }
  }

  static String _getDeadliftRPE(String phase) {
    switch (phase) {
      case 'accumulation': return '7-8';
      case 'intensification': return '8-9';
      case 'peaking': return '9-10';
      default: return '8';
    }
  }

  static String _getWorkoutRPE(String phase) {
    switch (phase) {
      case 'accumulation': return '7-8 RPE';
      case 'intensification': return '8-9 RPE';
      case 'peaking': return '9-10 RPE';
      default: return '8 RPE';
    }
  }

  static int _getWorkoutDuration(String phase, String type) {
    final baseDuration = type == 'main' ? 90 : 60;
    switch (phase) {
      case 'accumulation': return baseDuration + 15;
      case 'intensification': return baseDuration;
      case 'peaking': return baseDuration - 15;
      default: return baseDuration;
    }
  }

  static ProgramMetadata _createMetadata() {
    return ProgramMetadata(
      author: 'GZCL UHF Team',
      version: '1.0.0',
      createdDate: DateTime.now(),
      tags: ['powerlifting', 'strength', 'hip-aware', 'intermediate'],
      sourceUrl: 'https://gzcl-uhf.com/programs/hip-aware',
      customFields: {
        'target_audience': 'Intermediate powerlifters with hip imbalances',
        'specialization': 'Hip-aware powerlifting',
        'equipment_minimal': false,
        'time_commitment': 'High',
      },
    );
  }

  static ProgressionLogic _createProgressionLogic() {
    return ProgressionLogic(
      type: ProgressionType.periodized,
      parameters: {
        'autoregulation': true,
        'hip_emphasis': true,
        'phase_based': true,
      },
      rules: [
        ProgressionRule(
          id: 'main_lift_progression',
          name: 'Main Lift Periodized Progression',
          applicableExercises: ['squat', 'bench', 'deadlift'],
          formula: ProgressionFormula(
            type: FormulaType.percentage,
            expression: 'phase_based_percentage',
            constants: {
              'accumulation_base': 0.75,
              'intensification_base': 0.85,
              'peaking_base': 0.95,
              'weekly_increase': 0.025,
            },
          ),
        ),
        ProgressionRule(
          id: 'accessory_progression',
          name: 'Accessory Linear Progression',
          applicableExercises: ['accessory'],
          formula: ProgressionFormula(
            type: FormulaType.linear,
            expression: 'weekly_increase',
            constants: {
              'weekly_increase': 2.5,
            },
          ),
        ),
      ],
      autoregulationRules: {
        'squat': AutoregulationRule(
          trigger: 'rpe_high',
          conditions: {'average_rpe': {'operator': '>', 'value': 9.0}},
          adjustments: {'weight_reduction': 0.05},
        ),
        'bench': AutoregulationRule(
          trigger: 'rpe_high',
          conditions: {'average_rpe': {'operator': '>', 'value': 9.0}},
          adjustments: {'weight_reduction': 0.05},
        ),
        'deadlift': AutoregulationRule(
          trigger: 'rpe_high',
          conditions: {'average_rpe': {'operator': '>', 'value': 9.0}},
          adjustments: {'weight_reduction': 0.05},
        ),
      },
    );
  }
}