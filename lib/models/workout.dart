import 'package:hive/hive.dart';
import 'exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 14)
class Workout extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String dayName; // "monday", "tuesday", etc.

  @HiveField(2)
  String workoutName; // "Squat Focus + Hip Activation"

  @HiveField(3)
  int weekNumber;

  @HiveField(4)
  String blockPhase;

  @HiveField(5)
  List<Exercise> exercises;

  @HiveField(6)
  bool requiresHipActivation;

  @HiveField(7)
  List<String> keyFocusPoints;

  @HiveField(8)
  String? specialInstructions;

  @HiveField(9)
  String targetRPERange; // "6-8", "7-9", etc.

  @HiveField(10)
  int estimatedDuration; // minutes

  Workout({
    required this.id,
    required this.dayName,
    required this.workoutName,
    required this.weekNumber,
    required this.blockPhase,
    required this.exercises,
    required this.requiresHipActivation,
    required this.keyFocusPoints,
    this.specialInstructions,
    required this.targetRPERange,
    required this.estimatedDuration,
  });

  // Apply hip logic to all exercises in the workout
  Workout applyHipLogic(String hipSide) {
    List<Exercise> modifiedExercises = exercises
        .map((exercise) => exercise.applyHipLogic(hipSide))
        .toList();

    return Workout(
      id: id,
      dayName: dayName,
      workoutName: workoutName,
      weekNumber: weekNumber,
      blockPhase: blockPhase,
      exercises: modifiedExercises,
      requiresHipActivation: requiresHipActivation,
      keyFocusPoints: keyFocusPoints,
      specialInstructions: specialInstructions,
      targetRPERange: targetRPERange,
      estimatedDuration: estimatedDuration,
    );
  }

  // Get hip activation exercises if required
  static List<Exercise> getHipActivationCircuit() {
    return [
      Exercise(
        name: "Clamshells",
        sets: 2,
        reps: "15 each",
        weight: "Light band",
        type: "warmup",
        cues: ["Focus on glute activation", "Control the movement"],
        isUnilateral: true,
        muscleGroup: "glutes",
        equipment: "band",
        requiresHipActivation: true,
      ),
      Exercise(
        name: "Side-lying Hip Abduction",
        sets: 2,
        reps: "12 each",
        weight: "Band",
        type: "warmup",
        cues: ["Maintain neutral spine", "Feel it in hip/glute"],
        isUnilateral: true,
        muscleGroup: "glutes",
        equipment: "band",
        requiresHipActivation: true,
      ),
      Exercise(
        name: "Single-leg Glute Bridges",
        sets: 2,
        reps: "10 each",
        weight: "Bodyweight",
        type: "warmup",
        cues: ["Drive through heel", "Squeeze glutes at top"],
        isUnilateral: true,
        muscleGroup: "glutes",
        requiresHipActivation: true,
      ),
    ];
  }

  // Generate daily focus points based on day and program phase
  static List<String> generateFocusPoints(String dayName, int week, String block) {
    Map<String, List<String>> baseFocusPoints = {
      "monday": [
        "Hip activation is mandatory",
        "Focus on squat depth and control",
        "Start split squats with left leg",
        "Maintain neutral spine throughout"
      ],
      "tuesday": [
        "Warm up shoulders thoroughly",
        "Control the incline press tempo",
        "Focus on upper back posture",
        "Retract shoulder blades on rows"
      ],
      "wednesday": [
        "Hip circles before lifting",
        "Maintain neutral spine on deadlifts",
        "Single-leg work for hip stability",
        "Piriformis stretch in cool-down"
      ],
      "thursday": [
        "Higher volume day - pace yourself",
        "Focus on muscle connection",
        "Moderate intensity focus",
        "Quality over quantity"
      ],
      "friday": [
        "Hip stability is the priority",
        "Quality movement over heavy weight",
        "End with thorough mobility work",
        "Left leg first on all unilateral work"
      ]
    };

    List<String> points = List.from(baseFocusPoints[dayName] ?? ["Focus on form and consistency"]);

    // Add week-specific guidance
    if (week <= 2) {
      points.add("RPE should feel like 6-7 today");
    } else if (week <= 4) {
      points.add("RPE target: 7-8 for main lifts");
    } else if (week == 5) {
      points.add("Peak week - RPE 8-9, push safely");
    } else if (week == 6 || week == 12) {
      points.add("Deload week - reduce intensity 20-30%");
    } else if (week >= 17) {
      points.add("Competition prep - focus on technique");
    }

    // Add block-specific guidance
    switch (block) {
      case "Accumulation":
        points.add("Volume building phase - consistency is key");
        break;
      case "Intensification":
        points.add("Strength building phase - intensity matters");
        break;
      case "Peaking":
        points.add("Max strength phase - every rep counts");
        break;
    }

    return points;
  }

  // Check if hip activation is required for this day
  static bool requiresHipActivationForDay(String dayName) {
    return ['monday', 'wednesday', 'friday'].contains(dayName.toLowerCase());
  }

  // Get total volume load for the workout
  double getTotalVolumeLoad(Map<String, int> userMaxes) {
    double totalVolume = 0.0;
    
    for (Exercise exercise in exercises) {
      if (exercise.type == 'main' || exercise.type == 'accessory') {
        double weight = exercise.calculateWeight(userMaxes);
        int repsPerSet = exercise.reps is int ? exercise.reps : 8; // Default estimate
        totalVolume += weight * repsPerSet * exercise.sets;
      }
    }
    
    return totalVolume;
  }
}