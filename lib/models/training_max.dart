import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'training_max.g.dart';

@HiveType(typeId: 0)
class TrainingMax extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String exercise;
  
  @HiveField(2)
  final double weight;
  
  @HiveField(3)
  final DateTime lastTested;
  
  @HiveField(4)
  final List<AMRAPResult> recentResults;
  
  @HiveField(5)
  final bool isActive;

  const TrainingMax({
    required this.id,
    required this.exercise,
    required this.weight,
    required this.lastTested,
    this.recentResults = const [],
    this.isActive = true,
  });

  TrainingMax copyWith({
    String? id,
    String? exercise,
    double? weight,
    DateTime? lastTested,
    List<AMRAPResult>? recentResults,
    bool? isActive,
  }) {
    return TrainingMax(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      weight: weight ?? this.weight,
      lastTested: lastTested ?? this.lastTested,
      recentResults: recentResults ?? this.recentResults,
      isActive: isActive ?? this.isActive,
    );
  }

  double getTrainingMaxPercentage(double percentage) {
    return weight * (percentage / 100);
  }

  @override
  List<Object?> get props => [id, exercise, weight, lastTested, recentResults, isActive];
}

@HiveType(typeId: 1)
class AMRAPResult extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final double weight;
  
  @HiveField(2)
  final int reps;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final double rpe;
  
  @HiveField(5)
  final String notes;

  const AMRAPResult({
    required this.id,
    required this.weight,
    required this.reps,
    required this.date,
    required this.rpe,
    this.notes = '',
  });

  double get estimatedOneRepMax {
    return weight * (1 + 0.0333 * reps);
  }

  @override
  List<Object?> get props => [id, weight, reps, date, rpe, notes];
}