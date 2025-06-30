import 'package:hive/hive.dart';
import 'program.dart';

part 'program_history.g.dart';

@HiveType(typeId: 34)
class ProgramHistory extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  List<CompletedProgram> completedPrograms;

  @HiveField(2)
  ActiveProgram? currentProgram;

  @HiveField(3)
  List<ProgramTemplate> savedTemplates;

  @HiveField(4)
  DateTime lastUpdated;

  ProgramHistory({
    required this.userId,
    this.completedPrograms = const [],
    this.currentProgram,
    this.savedTemplates = const [],
    required this.lastUpdated,
  });

  // Get all programs (completed + current)
  List<ProgramRecord> getAllPrograms() {
    final allPrograms = <ProgramRecord>[];
    allPrograms.addAll(completedPrograms);
    if (currentProgram != null) {
      allPrograms.add(currentProgram!);
    }
    return allPrograms..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Get total training experience
  Duration getTotalTrainingTime() {
    final totalDays = completedPrograms.fold<int>(0, (sum, program) => 
      sum + program.actualDuration.inDays);
    
    if (currentProgram != null) {
      final currentDays = DateTime.now().difference(currentProgram!.startDate).inDays;
      return Duration(days: totalDays + currentDays);
    }
    
    return Duration(days: totalDays);
  }

  // Get strength progression across all programs
  Map<String, StrengthProgression> getStrengthProgression() {
    final progressions = <String, StrengthProgression>{};
    
    for (final program in getAllPrograms()) {
      for (final lift in program.startingMaxes.keys) {
        if (!progressions.containsKey(lift)) {
          progressions[lift] = StrengthProgression(lift: lift);
        }
        
        progressions[lift]!.dataPoints.add(
          StrengthDataPoint(
            date: program.startDate,
            weight: program.startingMaxes[lift]!,
            programName: program.programName,
            isStarting: true,
          ),
        );
        
        if (program is CompletedProgram) {
          progressions[lift]!.dataPoints.add(
            StrengthDataPoint(
              date: program.endDate,
              weight: program.finalMaxes[lift] ?? program.startingMaxes[lift]!,
              programName: program.programName,
              isStarting: false,
            ),
          );
        }
      }
    }
    
    // Sort data points by date
    for (final progression in progressions.values) {
      progression.dataPoints.sort((a, b) => a.date.compareTo(b.date));
    }
    
    return progressions;
  }

  // Check if user can switch programs
  bool canSwitchPrograms() {
    if (currentProgram == null) return true;
    
    // Allow switching after completing at least 2 weeks
    final weeksCompleted = DateTime.now().difference(currentProgram!.startDate).inDays / 7;
    return weeksCompleted >= 2;
  }

  // Get momentum warning message
  String getMomentumWarning() {
    if (currentProgram == null) return '';
    
    final daysInProgram = DateTime.now().difference(currentProgram!.startDate).inDays;
    final weeksInProgram = daysInProgram / 7;
    
    if (weeksInProgram < 2) {
      return 'You\'ve only been on this program for $daysInProgram days. Early switching can hurt progress.';
    } else if (weeksInProgram < 4) {
      return 'You\'re ${weeksInProgram.round()} weeks into your program. Consider the momentum you\'ll lose.';
    } else {
      return 'You\'ve invested ${weeksInProgram.round()} weeks. Are you sure you want to lose this momentum?';
    }
  }

  // Add completed program
  void addCompletedProgram(CompletedProgram program) {
    completedPrograms.add(program);
    currentProgram = null;
    lastUpdated = DateTime.now();
    save();
  }

  // Start new program
  void startNewProgram(ActiveProgram program) {
    // Archive current program if exists
    if (currentProgram != null) {
      final incomplete = CompletedProgram.fromActive(
        currentProgram!,
        CompletionStatus.incomplete,
        'Program switched before completion',
      );
      completedPrograms.add(incomplete);
    }
    
    currentProgram = program;
    lastUpdated = DateTime.now();
    save();
  }
}

@HiveType(typeId: 35)
class ProgramRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String programName;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  Map<String, int> startingMaxes;

  @HiveField(4)
  String programVersion;

  ProgramRecord({
    required this.id,
    required this.programName,
    required this.startDate,
    required this.startingMaxes,
    required this.programVersion,
  });
}

@HiveType(typeId: 36)
class ActiveProgram extends ProgramRecord {
  @HiveField(10)
  int currentWeek;

  @HiveField(11)
  String currentPhase;

  @HiveField(12)
  Map<String, int> currentMaxes;

  @HiveField(13)
  List<String> completedWorkouts;

  @HiveField(14)
  Map<String, dynamic> progressData;

  @HiveField(15)
  String? userNotes;

  ActiveProgram({
    required super.id,
    required super.programName,
    required super.startDate,
    required super.startingMaxes,
    required super.programVersion,
    required this.currentWeek,
    required this.currentPhase,
    required this.currentMaxes,
    this.completedWorkouts = const [],
    this.progressData = const {},
    this.userNotes,
  });

  // Calculate progress percentage
  double getProgressPercentage(int totalWeeks) {
    return (currentWeek / totalWeeks).clamp(0.0, 1.0);
  }

  // Get days in program
  int getDaysInProgram() {
    return DateTime.now().difference(startDate).inDays;
  }

  // Update progress
  void updateProgress({
    int? week,
    String? phase,
    Map<String, int>? maxes,
    String? notes,
  }) {
    if (week != null) currentWeek = week;
    if (phase != null) currentPhase = phase;
    if (maxes != null) currentMaxes = {...currentMaxes, ...maxes};
    if (notes != null) userNotes = notes;
    save();
  }
}

@HiveType(typeId: 37)
class CompletedProgram extends ProgramRecord {
  @HiveField(20)
  DateTime endDate;

  @HiveField(21)
  Map<String, int> finalMaxes;

  @HiveField(22)
  CompletionStatus status;

  @HiveField(23)
  ProgramResults results;

  @HiveField(24)
  String? userReview;

  @HiveField(25)
  int? rating; // 1-5 stars

  @HiveField(26)
  Duration actualDuration;

  CompletedProgram({
    required super.id,
    required super.programName,
    required super.startDate,
    required super.startingMaxes,
    required super.programVersion,
    required this.endDate,
    required this.finalMaxes,
    required this.status,
    required this.results,
    this.userReview,
    this.rating,
    required this.actualDuration,
  });

  // Create from active program
  factory CompletedProgram.fromActive(
    ActiveProgram active,
    CompletionStatus status,
    String? review,
  ) {
    final endDate = DateTime.now();
    return CompletedProgram(
      id: active.id,
      programName: active.programName,
      startDate: active.startDate,
      startingMaxes: active.startingMaxes,
      programVersion: active.programVersion,
      endDate: endDate,
      finalMaxes: active.currentMaxes,
      status: status,
      results: ProgramResults.fromActiveProgram(active),
      userReview: review,
      actualDuration: endDate.difference(active.startDate),
    );
  }

  // Calculate total strength gains
  Map<String, int> getStrengthGains() {
    final gains = <String, int>{};
    for (final lift in startingMaxes.keys) {
      final start = startingMaxes[lift]!;
      final end = finalMaxes[lift] ?? start;
      gains[lift] = end - start;
    }
    return gains;
  }

  // Get total strength gain percentage
  double getTotalGainPercentage() {
    double totalGainPercentage = 0;
    int liftCount = 0;
    
    for (final lift in startingMaxes.keys) {
      final start = startingMaxes[lift]!;
      final end = finalMaxes[lift] ?? start;
      if (start > 0) {
        totalGainPercentage += (end - start) / start;
        liftCount++;
      }
    }
    
    return liftCount > 0 ? (totalGainPercentage / liftCount) * 100 : 0;
  }
}

@HiveType(typeId: 38)
enum CompletionStatus {
  @HiveField(0)
  completed,
  @HiveField(1)
  incomplete,
  @HiveField(2)
  abandoned,
  @HiveField(3)
  injury,
}

@HiveType(typeId: 39)
class ProgramResults extends HiveObject {
  @HiveField(0)
  Map<String, int> strengthGains;

  @HiveField(1)
  int totalWorkoutsCompleted;

  @HiveField(2)
  int totalWorkoutsPlanned;

  @HiveField(3)
  double adherencePercentage;

  @HiveField(4)
  Map<String, double> averageRPE;

  @HiveField(5)
  List<String> personalRecords;

  @HiveField(6)
  Map<String, dynamic> customMetrics;

  ProgramResults({
    required this.strengthGains,
    required this.totalWorkoutsCompleted,
    required this.totalWorkoutsPlanned,
    required this.adherencePercentage,
    this.averageRPE = const {},
    this.personalRecords = const [],
    this.customMetrics = const {},
  });

  factory ProgramResults.fromActiveProgram(ActiveProgram active) {
    final strengthGains = <String, int>{};
    for (final lift in active.startingMaxes.keys) {
      final start = active.startingMaxes[lift]!;
      final current = active.currentMaxes[lift] ?? start;
      strengthGains[lift] = current - start;
    }

    return ProgramResults(
      strengthGains: strengthGains,
      totalWorkoutsCompleted: active.completedWorkouts.length,
      totalWorkoutsPlanned: 0, // Would be calculated from program
      adherencePercentage: 0.0, // Would be calculated
    );
  }
}

@HiveType(typeId: 40)
class StrengthProgression extends HiveObject {
  @HiveField(0)
  String lift;

  @HiveField(1)
  List<StrengthDataPoint> dataPoints;

  StrengthProgression({
    required this.lift,
    this.dataPoints = const [],
  });

  // Get total progression
  int getTotalGain() {
    if (dataPoints.length < 2) return 0;
    return dataPoints.last.weight - dataPoints.first.weight;
  }

  // Get progression rate (kg per month)
  double getProgressionRate() {
    if (dataPoints.length < 2) return 0;
    
    final firstPoint = dataPoints.first;
    final lastPoint = dataPoints.last;
    final monthsDiff = lastPoint.date.difference(firstPoint.date).inDays / 30.44;
    
    if (monthsDiff <= 0) return 0;
    return (lastPoint.weight - firstPoint.weight) / monthsDiff;
  }
}

@HiveType(typeId: 41)
class StrengthDataPoint extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int weight;

  @HiveField(2)
  String programName;

  @HiveField(3)
  bool isStarting;

  StrengthDataPoint({
    required this.date,
    required this.weight,
    required this.programName,
    required this.isStarting,
  });
}

@HiveType(typeId: 42)
class ProgramTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Program program;

  @HiveField(3)
  Map<String, dynamic> userCustomizations;

  @HiveField(4)
  DateTime createdDate;

  @HiveField(5)
  int usageCount;

  ProgramTemplate({
    required this.id,
    required this.name,
    required this.program,
    this.userCustomizations = const {},
    required this.createdDate,
    this.usageCount = 0,
  });

  // Create program instance from template
  Program createProgramInstance(Map<String, int> userMaxes) {
    // Apply user customizations and maxes to create a new program instance
    // This would involve cloning the program and applying user-specific data
    return program; // Placeholder
  }
}