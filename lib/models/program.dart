import 'package:hive/hive.dart';
import 'phase.dart';
import 'progression_logic.dart';

part 'program.g.dart';

@HiveType(typeId: 20)
class Program extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  ProgramType type;

  @HiveField(4)
  List<Phase> phases;

  @HiveField(5)
  ProgramMetadata metadata;

  @HiveField(6)
  ProgressionLogic progressionLogic;

  @HiveField(7)
  List<String> requiredEquipment;

  @HiveField(8)
  DifficultyLevel difficulty;

  @HiveField(9)
  ProgramDuration estimatedDuration;

  Program({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.phases,
    required this.metadata,
    required this.progressionLogic,
    this.requiredEquipment = const [],
    this.difficulty = DifficultyLevel.intermediate,
    required this.estimatedDuration,
  });

  // Get total number of weeks
  int get totalWeeks => phases.fold(0, (sum, phase) => sum + phase.durationWeeks);

  // Get current phase based on week
  Phase? getPhaseForWeek(int week) {
    int weekCounter = 0;
    for (final phase in phases) {
      if (week <= weekCounter + phase.durationWeeks) {
        return phase;
      }
      weekCounter += phase.durationWeeks;
    }
    return null;
  }

  // Get phase index for a given week
  int getPhaseIndexForWeek(int week) {
    int weekCounter = 0;
    for (int i = 0; i < phases.length; i++) {
      if (week <= weekCounter + phases[i].durationWeeks) {
        return i;
      }
      weekCounter += phases[i].durationWeeks;
    }
    return phases.length - 1;
  }

  // Validate program structure
  bool isValid() {
    if (phases.isEmpty) return false;
    if (totalWeeks <= 0) return false;
    return phases.every((phase) => phase.isValid());
  }
}

@HiveType(typeId: 21)
enum ProgramType {
  @HiveField(0)
  powerlifting,
  @HiveField(1)
  strengthBuilding,
  @HiveField(2)
  hypertrophy,
  @HiveField(3)
  peaking,
  @HiveField(4)
  rehabilitation,
}

@HiveType(typeId: 22)
enum DifficultyLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
  @HiveField(3)
  elite,
}

@HiveType(typeId: 23)
class ProgramMetadata extends HiveObject {
  @HiveField(0)
  String author;

  @HiveField(1)
  String version;

  @HiveField(2)
  DateTime createdDate;

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  String? sourceUrl;

  @HiveField(5)
  Map<String, dynamic> customFields;

  ProgramMetadata({
    required this.author,
    required this.version,
    required this.createdDate,
    this.tags = const [],
    this.sourceUrl,
    this.customFields = const {},
  });
}

@HiveType(typeId: 24)
class ProgramDuration extends HiveObject {
  @HiveField(0)
  int weeks;

  @HiveField(1)
  int? days;

  ProgramDuration({
    required this.weeks,
    this.days,
  });

  int get totalDays => (weeks * 7) + (days ?? 0);
  
  @override
  String toString() {
    if (days != null && days! > 0) {
      return '$weeks weeks, $days days';
    }
    return '$weeks weeks';
  }
}