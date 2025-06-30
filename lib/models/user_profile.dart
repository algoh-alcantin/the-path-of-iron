import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 12)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int currentWeek; // 1-18

  @HiveField(2)
  String currentBlock; // "Accumulation", "Intensification", "Peaking"

  @HiveField(3)
  Map<String, int> currentMaxes; // {"inclineBench": 165, "squat": 225, "deadlift": 315}

  @HiveField(4)
  Map<String, int> targetMaxes; // {"inclineBench": 225, "squat": 315, "deadlift": 405}

  @HiveField(5)
  bool hipIssues; // true

  @HiveField(6)
  String hipSide; // "left"

  @HiveField(7)
  DateTime programStartDate;

  @HiveField(8)
  List<String> completedWorkouts;

  @HiveField(9)
  int trainingExperience; // months

  @HiveField(10)
  String experienceLevel; // "Intermediate"

  @HiveField(11)
  int trainingFrequency; // days per week

  @HiveField(12)
  bool isActive;

  UserProfile({
    required this.name,
    required this.currentWeek,
    required this.currentBlock,
    required this.currentMaxes,
    required this.targetMaxes,
    required this.hipIssues,
    required this.hipSide,
    required this.programStartDate,
    required this.completedWorkouts,
    required this.trainingExperience,
    required this.experienceLevel,
    required this.trainingFrequency,
    this.isActive = true,
  });

  // Calculate which phase we're in based on current week
  String get currentPhase {
    if (currentWeek <= 6) return "Accumulation";
    if (currentWeek <= 12) return "Intensification";
    return "Peaking";
  }

  // Get target intensity range for current week
  Map<String, double> get currentIntensityRange {
    return getIntensityByWeek(currentWeek, currentPhase);
  }

  // Calculate progress percentage through program
  double get programProgress {
    return (currentWeek / 18.0).clamp(0.0, 1.0);
  }

  // Calculate expected gains based on intermediate progression
  Map<String, double> get expectedProgressPercent {
    double progressFactor = programProgress;
    return {
      'inclineBench': 25 * progressFactor, // 25% gain expected
      'squat': 30 * progressFactor,        // 30% gain expected
      'deadlift': 40 * progressFactor,     // 40% gain expected
    };
  }

  static Map<String, double> getIntensityByWeek(int week, String block) {
    switch (block) {
      case "Accumulation":
        if (week <= 2) return {"min": 0.70, "max": 0.75};
        if (week <= 4) return {"min": 0.75, "max": 0.80};
        if (week == 5) return {"min": 0.80, "max": 0.85};
        return {"min": 0.60, "max": 0.70}; // Deload week 6
      
      case "Intensification":
        if (week <= 8) return {"min": 0.80, "max": 0.85};
        if (week <= 10) return {"min": 0.85, "max": 0.90};
        if (week == 11) return {"min": 0.90, "max": 0.95};
        return {"min": 0.70, "max": 0.75}; // Deload week 12
      
      case "Peaking":
        if (week <= 14) return {"min": 0.90, "max": 0.95};
        if (week <= 16) return {"min": 0.95, "max": 1.00};
        if (week == 17) return {"min": 0.70, "max": 0.80}; // Technique week
        return {"min": 0.95, "max": 1.05}; // Testing week 18
      
      default:
        return {"min": 0.70, "max": 0.80};
    }
  }
}