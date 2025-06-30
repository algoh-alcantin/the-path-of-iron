import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 13)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int sets;

  @HiveField(2)
  dynamic reps; // Can be int or String ("8 each", "10-15")

  @HiveField(3)
  dynamic weight; // Can be String ("75%") or double (135.0)

  @HiveField(4)
  String type; // "main", "accessory", "unilateral", "warmup", "corrective"

  @HiveField(5)
  List<String> cues; // Movement cues and reminders

  @HiveField(6)
  bool isUnilateral; // For hip-specific logic

  @HiveField(7)
  String muscleGroup; // For volume tracking

  @HiveField(8)
  String? equipment; // "barbell", "dumbbell", "cable", "band", etc.

  @HiveField(9)
  int? restPeriod; // seconds

  @HiveField(10)
  String? rpeTarget; // "7-8", "8-9", etc.

  @HiveField(11)
  String? specialInstructions;

  @HiveField(12)
  bool requiresHipActivation;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.type,
    required this.cues,
    required this.isUnilateral,
    required this.muscleGroup,
    this.equipment,
    this.restPeriod,
    this.rpeTarget,
    this.specialInstructions,
    this.requiresHipActivation = false,
  });

  // Calculate actual weight based on user's maxes
  double calculateWeight(Map<String, int> maxes) {
    if (weight is String && weight.toString().contains('%')) {
      int percentage = int.parse(weight.toString().replaceAll('%', ''));
      
      // Determine which max to use based on exercise name
      String exerciseLower = name.toLowerCase();
      if (exerciseLower.contains('squat') && !exerciseLower.contains('front')) {
        return (percentage / 100.0) * maxes['squat']!;
      } else if (exerciseLower.contains('bench') || exerciseLower.contains('incline')) {
        return (percentage / 100.0) * maxes['inclineBench']!;
      } else if (exerciseLower.contains('deadlift') && !exerciseLower.contains('romanian')) {
        return (percentage / 100.0) * maxes['deadlift']!;
      }
    }
    
    // Return as-is if not percentage-based
    return weight is double ? weight : (weight is int ? weight.toDouble() : 0.0);
  }

  // Apply hip-specific logic for unilateral exercises
  Exercise applyHipLogic(String hipSide) {
    if (isUnilateral) {
      // Add reminder to start with weaker side
      List<String> modifiedCues = List.from(cues);
      modifiedCues.insert(0, "START WITH ${hipSide.toUpperCase()} LEG FIRST");
      
      // Modify reps notation if needed
      String modifiedReps = reps.toString();
      if (modifiedReps.contains('each')) {
        modifiedReps = "$modifiedReps (${hipSide.toUpperCase()} FIRST)";
      }
      
      return Exercise(
        name: name,
        sets: sets,
        reps: modifiedReps,
        weight: weight,
        type: type,
        cues: modifiedCues,
        isUnilateral: isUnilateral,
        muscleGroup: muscleGroup,
        equipment: equipment,
        restPeriod: restPeriod,
        rpeTarget: rpeTarget,
        specialInstructions: specialInstructions,
        requiresHipActivation: requiresHipActivation,
      );
    }
    return this;
  }

  // Get recommended rest period based on exercise type
  int getRecommendedRestPeriod(String currentPhase) {
    if (restPeriod != null) return restPeriod!;
    
    switch (type) {
      case 'main':
        switch (currentPhase) {
          case 'Accumulation':
            return 180; // 3 minutes
          case 'Intensification':
            return 240; // 4 minutes
          case 'Peaking':
            return 300; // 5+ minutes
          default:
            return 180;
        }
      case 'accessory':
        return currentPhase == 'Peaking' ? 180 : 120; // 2-3 minutes
      case 'unilateral':
      case 'corrective':
        return 90; // 90 seconds
      case 'warmup':
        return 30; // 30 seconds
      default:
        return 120;
    }
  }

  // Get color based on exercise type for UI
  String get typeColor {
    switch (type) {
      case 'main':
        return 'sanguineRed';
      case 'accessory':
        return 'goldenKoi';
      case 'unilateral':
        return 'contemplativeBlue';
      case 'corrective':
        return 'honorableGreen';
      case 'warmup':
        return 'sakuraPink';
      default:
        return 'ashWhite';
    }
  }
}