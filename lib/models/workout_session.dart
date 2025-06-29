import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 2)
class WorkoutSession extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  final int weekNumber;
  
  @HiveField(3)
  final int dayNumber;
  
  @HiveField(4)
  final List<ExerciseSet> sets;
  
  @HiveField(5)
  final Duration totalDuration;
  
  @HiveField(6)
  final SubjectiveMarkers subjectiveMarkers;
  
  @HiveField(7)
  final bool isCompleted;
  
  @HiveField(8)
  final String notes;

  const WorkoutSession({
    required this.id,
    required this.date,
    required this.weekNumber,
    required this.dayNumber,
    this.sets = const [],
    this.totalDuration = Duration.zero,
    required this.subjectiveMarkers,
    this.isCompleted = false,
    this.notes = '',
  });

  WorkoutSession copyWith({
    String? id,
    DateTime? date,
    int? weekNumber,
    int? dayNumber,
    List<ExerciseSet>? sets,
    Duration? totalDuration,
    SubjectiveMarkers? subjectiveMarkers,
    bool? isCompleted,
    String? notes,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      weekNumber: weekNumber ?? this.weekNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      sets: sets ?? this.sets,
      totalDuration: totalDuration ?? this.totalDuration,
      subjectiveMarkers: subjectiveMarkers ?? this.subjectiveMarkers,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  double get totalVolumeLoad {
    return sets.fold(0.0, (total, set) => total + set.volumeLoad);
  }

  @override
  List<Object?> get props => [
    id, date, weekNumber, dayNumber, sets, 
    totalDuration, subjectiveMarkers, isCompleted, notes
  ];
}

@HiveType(typeId: 3)
class ExerciseSet extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String exercise;
  
  @HiveField(2)
  final TierType tier;
  
  @HiveField(3)
  final double weight;
  
  @HiveField(4)
  final int targetReps;
  
  @HiveField(5)
  final int actualReps;
  
  @HiveField(6)
  final double rpe;
  
  @HiveField(7)
  final bool isAMRAP;
  
  @HiveField(8)
  final Duration restTime;
  
  @HiveField(9)
  final String notes;

  const ExerciseSet({
    required this.id,
    required this.exercise,
    required this.tier,
    required this.weight,
    required this.targetReps,
    this.actualReps = 0,
    this.rpe = 0.0,
    this.isAMRAP = false,
    this.restTime = Duration.zero,
    this.notes = '',
  });

  ExerciseSet copyWith({
    String? id,
    String? exercise,
    TierType? tier,
    double? weight,
    int? targetReps,
    int? actualReps,
    double? rpe,
    bool? isAMRAP,
    Duration? restTime,
    String? notes,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      tier: tier ?? this.tier,
      weight: weight ?? this.weight,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      rpe: rpe ?? this.rpe,
      isAMRAP: isAMRAP ?? this.isAMRAP,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
    );
  }

  double get volumeLoad => weight * actualReps;

  bool get isCompleted => actualReps > 0;

  @override
  List<Object?> get props => [
    id, exercise, tier, weight, targetReps, 
    actualReps, rpe, isAMRAP, restTime, notes
  ];
}

@HiveType(typeId: 4)
enum TierType {
  @HiveField(0)
  t1,
  @HiveField(1)
  t2,
  @HiveField(2)
  t3,
}

@HiveType(typeId: 5)
class SubjectiveMarkers extends Equatable {
  @HiveField(0)
  final double energy;
  
  @HiveField(1)
  final double motivation;
  
  @HiveField(2)
  final double soreness;
  
  @HiveField(3)
  final double sleepQuality;
  
  @HiveField(4)
  final double stressLevel;

  const SubjectiveMarkers({
    required this.energy,
    required this.motivation,
    required this.soreness,
    required this.sleepQuality,
    required this.stressLevel,
  });

  SubjectiveMarkers copyWith({
    double? energy,
    double? motivation,
    double? soreness,
    double? sleepQuality,
    double? stressLevel,
  }) {
    return SubjectiveMarkers(
      energy: energy ?? this.energy,
      motivation: motivation ?? this.motivation,
      soreness: soreness ?? this.soreness,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
    );
  }

  double get recoveryScore {
    return (energy + motivation + (10 - soreness) + sleepQuality + (10 - stressLevel)) / 5;
  }

  @override
  List<Object?> get props => [energy, motivation, soreness, sleepQuality, stressLevel];
}