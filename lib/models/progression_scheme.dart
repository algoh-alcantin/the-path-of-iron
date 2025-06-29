import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'workout_session.dart';

part 'progression_scheme.g.dart';

@HiveType(typeId: 6)
class ProgressionScheme extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final TierType tier;
  
  @HiveField(2)
  final Map<int, WeeklyProgression> weeklyProgressions;
  
  @HiveField(3)
  final AutoregulationRules autoregulationRules;
  
  @HiveField(4)
  final bool isActive;

  const ProgressionScheme({
    required this.id,
    required this.tier,
    required this.weeklyProgressions,
    required this.autoregulationRules,
    this.isActive = true,
  });

  ProgressionScheme copyWith({
    String? id,
    TierType? tier,
    Map<int, WeeklyProgression>? weeklyProgressions,
    AutoregulationRules? autoregulationRules,
    bool? isActive,
  }) {
    return ProgressionScheme(
      id: id ?? this.id,
      tier: tier ?? this.tier,
      weeklyProgressions: weeklyProgressions ?? this.weeklyProgressions,
      autoregulationRules: autoregulationRules ?? this.autoregulationRules,
      isActive: isActive ?? this.isActive,
    );
  }

  WeeklyProgression? getWeekProgression(int week) {
    return weeklyProgressions[week];
  }

  @override
  List<Object?> get props => [id, tier, weeklyProgressions, autoregulationRules, isActive];
}

@HiveType(typeId: 7)
class WeeklyProgression extends Equatable {
  @HiveField(0)
  final int week;
  
  @HiveField(1)
  final Map<int, DailyProgression> dailyProgressions;
  
  @HiveField(2)
  final bool isDeloadWeek;

  const WeeklyProgression({
    required this.week,
    required this.dailyProgressions,
    this.isDeloadWeek = false,
  });

  WeeklyProgression copyWith({
    int? week,
    Map<int, DailyProgression>? dailyProgressions,
    bool? isDeloadWeek,
  }) {
    return WeeklyProgression(
      week: week ?? this.week,
      dailyProgressions: dailyProgressions ?? this.dailyProgressions,
      isDeloadWeek: isDeloadWeek ?? this.isDeloadWeek,
    );
  }

  DailyProgression? getDayProgression(int day) {
    return dailyProgressions[day];
  }

  @override
  List<Object?> get props => [week, dailyProgressions, isDeloadWeek];
}

@HiveType(typeId: 8)
class DailyProgression extends Equatable {
  @HiveField(0)
  final int day;
  
  @HiveField(1)
  final List<SetProgression> setProgressions;
  
  @HiveField(2)
  final double intensityModifier;

  const DailyProgression({
    required this.day,
    required this.setProgressions,
    this.intensityModifier = 1.0,
  });

  DailyProgression copyWith({
    int? day,
    List<SetProgression>? setProgressions,
    double? intensityModifier,
  }) {
    return DailyProgression(
      day: day ?? this.day,
      setProgressions: setProgressions ?? this.setProgressions,
      intensityModifier: intensityModifier ?? this.intensityModifier,
    );
  }

  @override
  List<Object?> get props => [day, setProgressions, intensityModifier];
}

@HiveType(typeId: 9)
class SetProgression extends Equatable {
  @HiveField(0)
  final double percentage;
  
  @HiveField(1)
  final RepScheme repScheme;
  
  @HiveField(2)
  final bool isAMRAP;
  
  @HiveField(3)
  final Duration restTime;

  const SetProgression({
    required this.percentage,
    required this.repScheme,
    this.isAMRAP = false,
    this.restTime = const Duration(minutes: 3),
  });

  SetProgression copyWith({
    double? percentage,
    RepScheme? repScheme,
    bool? isAMRAP,
    Duration? restTime,
  }) {
    return SetProgression(
      percentage: percentage ?? this.percentage,
      repScheme: repScheme ?? this.repScheme,
      isAMRAP: isAMRAP ?? this.isAMRAP,
      restTime: restTime ?? this.restTime,
    );
  }

  @override
  List<Object?> get props => [percentage, repScheme, isAMRAP, restTime];
}

@HiveType(typeId: 10)
class RepScheme extends Equatable {
  @HiveField(0)
  final int minReps;
  
  @HiveField(1)
  final int maxReps;
  
  @HiveField(2)
  final int targetReps;

  const RepScheme({
    required this.minReps,
    required this.maxReps,
    required this.targetReps,
  });

  RepScheme copyWith({
    int? minReps,
    int? maxReps,
    int? targetReps,
  }) {
    return RepScheme(
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      targetReps: targetReps ?? this.targetReps,
    );
  }

  bool isRepCountValid(int reps) {
    return reps >= minReps && reps <= maxReps;
  }

  @override
  List<Object?> get props => [minReps, maxReps, targetReps];
}

@HiveType(typeId: 11)
class AutoregulationRules extends Equatable {
  @HiveField(0)
  final double minTrainingMaxIncrease;
  
  @HiveField(1)
  final double maxTrainingMaxIncrease;
  
  @HiveField(2)
  final int minAMRAPRepsForIncrease;
  
  @HiveField(3)
  final double maxRPEForIncrease;
  
  @HiveField(4)
  final int consecutiveFailuresForDecrease;
  
  @HiveField(5)
  final double trainingMaxDecreaseAmount;

  const AutoregulationRules({
    this.minTrainingMaxIncrease = 0.025,
    this.maxTrainingMaxIncrease = 0.10,
    this.minAMRAPRepsForIncrease = 3,
    this.maxRPEForIncrease = 8.5,
    this.consecutiveFailuresForDecrease = 2,
    this.trainingMaxDecreaseAmount = 0.10,
  });

  AutoregulationRules copyWith({
    double? minTrainingMaxIncrease,
    double? maxTrainingMaxIncrease,
    int? minAMRAPRepsForIncrease,
    double? maxRPEForIncrease,
    int? consecutiveFailuresForDecrease,
    double? trainingMaxDecreaseAmount,
  }) {
    return AutoregulationRules(
      minTrainingMaxIncrease: minTrainingMaxIncrease ?? this.minTrainingMaxIncrease,
      maxTrainingMaxIncrease: maxTrainingMaxIncrease ?? this.maxTrainingMaxIncrease,
      minAMRAPRepsForIncrease: minAMRAPRepsForIncrease ?? this.minAMRAPRepsForIncrease,
      maxRPEForIncrease: maxRPEForIncrease ?? this.maxRPEForIncrease,
      consecutiveFailuresForDecrease: consecutiveFailuresForDecrease ?? this.consecutiveFailuresForDecrease,
      trainingMaxDecreaseAmount: trainingMaxDecreaseAmount ?? this.trainingMaxDecreaseAmount,
    );
  }

  @override
  List<Object?> get props => [
    minTrainingMaxIncrease,
    maxTrainingMaxIncrease,
    minAMRAPRepsForIncrease,
    maxRPEForIncrease,
    consecutiveFailuresForDecrease,
    trainingMaxDecreaseAmount,
  ];
}