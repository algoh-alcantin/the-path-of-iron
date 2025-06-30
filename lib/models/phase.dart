import 'package:hive/hive.dart';
import 'workout.dart';
import 'exercise.dart';

part 'phase.g.dart';

@HiveType(typeId: 25)
class Phase extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  PhaseType type;

  @HiveField(4)
  int durationWeeks;

  @HiveField(5)
  List<Workout> workoutTemplates;

  @HiveField(6)
  PhaseCharacteristics characteristics;

  @HiveField(7)
  Map<String, dynamic> phaseParameters;

  @HiveField(8)
  int sequenceNumber;

  Phase({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.durationWeeks,
    required this.workoutTemplates,
    required this.characteristics,
    this.phaseParameters = const {},
    required this.sequenceNumber,
  });

  // Get workout for specific week and day within this phase
  Workout? getWorkoutForDay(int weekInPhase, String dayName) {
    // Find the workout template for this day
    final template = workoutTemplates.firstWhere(
      (workout) => workout.dayName.toLowerCase() == dayName.toLowerCase(),
      orElse: () => workoutTemplates.first,
    );

    // Apply phase-specific modifications
    return _applyPhaseModifications(template, weekInPhase);
  }

  // Apply phase-specific modifications to workout
  Workout _applyPhaseModifications(Workout template, int weekInPhase) {
    // Clone the workout and apply phase progression
    final modifiedExercises = template.exercises.map((exercise) {
      return _applyExerciseProgression(exercise, weekInPhase);
    }).toList();

    return Workout(
      id: '${template.id}_week_$weekInPhase',
      dayName: template.dayName,
      workoutName: template.workoutName,
      weekNumber: weekInPhase,
      blockPhase: name,
      exercises: modifiedExercises,
      requiresHipActivation: template.requiresHipActivation,
      keyFocusPoints: template.keyFocusPoints,
      targetRPERange: _adjustRPEForWeek(template.targetRPERange, weekInPhase),
      estimatedDuration: template.estimatedDuration,
    );
  }

  // Apply exercise-specific progression based on phase
  Exercise _applyExerciseProgression(Exercise exercise, int weekInPhase) {
    // This will be implemented based on phase characteristics
    // For now, return the exercise as-is
    return exercise;
  }

  // Adjust RPE targets based on week in phase
  String _adjustRPEForWeek(String baseRPE, int weekInPhase) {
    // Apply phase-specific RPE progression
    switch (type) {
      case PhaseType.accumulation:
        return baseRPE; // Keep base RPE
      case PhaseType.intensification:
        return _increaseRPE(baseRPE, 0.5); // Slightly higher
      case PhaseType.peaking:
        return _increaseRPE(baseRPE, 1.0); // Higher intensity
      case PhaseType.deload:
        return _decreaseRPE(baseRPE, 1.0); // Lower intensity
      case PhaseType.testing:
        return '9-10 RPE'; // Max effort
    }
  }

  String _increaseRPE(String rpeRange, double increase) {
    // Simple RPE adjustment logic
    return rpeRange; // Placeholder
  }

  String _decreaseRPE(String rpeRange, double decrease) {
    // Simple RPE adjustment logic
    return rpeRange; // Placeholder
  }

  // Validate phase structure
  bool isValid() {
    if (durationWeeks <= 0) return false;
    if (workoutTemplates.isEmpty) return false;
    return workoutTemplates.every((workout) => workout.exercises.isNotEmpty);
  }

  // Get total volume for this phase
  int get totalWorkouts => durationWeeks * workoutTemplates.length;
}

@HiveType(typeId: 26)
enum PhaseType {
  @HiveField(0)
  accumulation,
  @HiveField(1)
  intensification,
  @HiveField(2)
  peaking,
  @HiveField(3)
  deload,
  @HiveField(4)
  testing,
}

@HiveType(typeId: 27)
class PhaseCharacteristics extends HiveObject {
  @HiveField(0)
  double volumeMultiplier;

  @HiveField(1)
  double intensityMultiplier;

  @HiveField(2)
  double frequencyMultiplier;

  @HiveField(3)
  Map<String, double> exerciseEmphasis;

  @HiveField(4)
  List<String> primaryGoals;

  @HiveField(5)
  Map<String, dynamic> specialFeatures;

  PhaseCharacteristics({
    this.volumeMultiplier = 1.0,
    this.intensityMultiplier = 1.0,
    this.frequencyMultiplier = 1.0,
    this.exerciseEmphasis = const {},
    this.primaryGoals = const [],
    this.specialFeatures = const {},
  });
}