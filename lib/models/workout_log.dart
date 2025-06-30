import 'package:hive/hive.dart';

part 'workout_log.g.dart';

@HiveType(typeId: 15)
class WorkoutLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String workoutId;

  @HiveField(2)
  DateTime completedDate;

  @HiveField(3)
  Map<String, List<WorkoutSet>> exerciseData; // exerciseId -> sets data

  @HiveField(4)
  String notes;

  @HiveField(5)
  int overallRPE; // 1-10

  @HiveField(6)
  bool hipDiscomfort;

  @HiveField(7)
  String? hipNotes;

  @HiveField(8)
  int duration; // minutes

  @HiveField(9)
  int hipComfortRating; // 1-10 (1 = severe discomfort, 10 = no issues)

  @HiveField(10)
  bool completedHipActivation;

  @HiveField(11)
  Map<String, dynamic>? additionalMetrics; // Extensible for future metrics

  WorkoutLog({
    required this.id,
    required this.workoutId,
    required this.completedDate,
    required this.exerciseData,
    required this.notes,
    required this.overallRPE,
    required this.hipDiscomfort,
    this.hipNotes,
    required this.duration,
    required this.hipComfortRating,
    required this.completedHipActivation,
    this.additionalMetrics,
  });

  // Calculate total volume load for this workout
  double get totalVolumeLoad {
    double total = 0.0;
    
    exerciseData.forEach((exerciseName, sets) {
      for (WorkoutSet set in sets) {
        if (set.completed) {
          total += set.weight * set.reps;
        }
      }
    });
    
    return total;
  }

  // Get completion rate (percentage of sets completed)
  double get completionRate {
    int totalSets = 0;
    int completedSets = 0;
    
    exerciseData.forEach((exerciseName, sets) {
      totalSets += sets.length;
      completedSets += sets.where((set) => set.completed).length;
    });
    
    return totalSets > 0 ? completedSets / totalSets : 0.0;
  }

  // Get average RPE for the workout
  double get averageRPE {
    List<int> rpes = [];
    
    exerciseData.forEach((exerciseName, sets) {
      for (WorkoutSet set in sets) {
        if (set.completed && set.rpe != null) {
          rpes.add(set.rpe!);
        }
      }
    });
    
    return rpes.isNotEmpty ? rpes.reduce((a, b) => a + b) / rpes.length : 0.0;
  }

  // Check if this workout had any personal records
  bool get hasPersonalRecord {
    return exerciseData.values
        .any((sets) => sets.any((set) => set.isPersonalRecord == true));
  }

  // Get estimated 1RM for main lifts from this workout
  Map<String, double> get estimated1RMs {
    Map<String, double> estimates = {};
    
    exerciseData.forEach((exerciseName, sets) {
      String liftType = _classifyLiftType(exerciseName);
      if (liftType != 'unknown') {
        // Find the heaviest completed set with RPE >= 8
        WorkoutSet? heaviestSet = sets
            .where((set) => set.completed && set.rpe != null && set.rpe! >= 8)
            .fold<WorkoutSet?>(null, (prev, current) {
              if (prev == null) return current;
              return current.weight > prev.weight ? current : prev;
            });
        
        if (heaviestSet != null) {
          // Use Epley formula: Weight * (1 + (Reps / 30))
          double estimated1RM = heaviestSet.weight * (1 + (heaviestSet.reps / 30));
          estimates[liftType] = estimated1RM;
        }
      }
    });
    
    return estimates;
  }

  String _classifyLiftType(String exerciseName) {
    String name = exerciseName.toLowerCase();
    if (name.contains('incline') && name.contains('bench')) return 'inclineBench';
    if (name.contains('squat') && !name.contains('front')) return 'squat';
    if (name.contains('deadlift') && !name.contains('romanian')) return 'deadlift';
    return 'unknown';
  }
}

@HiveType(typeId: 16)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int reps;

  @HiveField(2)
  int? rpe; // 1-10

  @HiveField(3)
  bool completed;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  bool? isPersonalRecord;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  int? restTime; // seconds actually rested

  WorkoutSet({
    required this.weight,
    required this.reps,
    this.rpe,
    required this.completed,
    this.notes,
    this.isPersonalRecord,
    this.completedAt,
    this.restTime,
  });

  // Calculate volume load for this set
  double get volumeLoad => weight * reps;

  // Get intensity based on estimated 1RM
  double getIntensity(double estimated1RM) {
    return estimated1RM > 0 ? weight / estimated1RM : 0.0;
  }

  // Check if this set meets RPE target range
  bool meetsRPETarget(String targetRange) {
    if (rpe == null) return false;
    
    if (targetRange.contains('-')) {
      List<String> parts = targetRange.split('-');
      int minRPE = int.tryParse(parts[0]) ?? 1;
      int maxRPE = int.tryParse(parts[1]) ?? 10;
      return rpe! >= minRPE && rpe! <= maxRPE;
    } else {
      int targetRPE = int.tryParse(targetRange) ?? 8;
      return rpe == targetRPE;
    }
  }
}