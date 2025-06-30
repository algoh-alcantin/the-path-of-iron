import '../models/program_history.dart';
import '../models/program.dart';
import '../repositories/hive_database.dart';

/// Core service for managing program lifecycle and history
class ProgramManagementService {
  static const String _programHistoryKey = 'program_history';
  
  // Get user's program history
  Future<ProgramHistory> getProgramHistory() async {
    final userProfileBox = HiveDatabase.userProfileBox;
    final programHistoryBox = HiveDatabase.userPreferencesBox;
    
    final userProfile = userProfileBox.get('current_user');
    final userId = userProfile?.name ?? 'default_user';
    
    var history = programHistoryBox.get(_programHistoryKey) as ProgramHistory?;
    
    if (history == null) {
      history = ProgramHistory(
        userId: userId,
        lastUpdated: DateTime.now(),
      );
      await _saveProgramHistory(history);
    }
    
    return history;
  }

  // Check if user has an active program
  Future<bool> hasActiveProgram() async {
    final history = await getProgramHistory();
    return history.currentProgram != null;
  }

  // Get current active program
  Future<ActiveProgram?> getCurrentProgram() async {
    final history = await getProgramHistory();
    return history.currentProgram;
  }

  // Start a new program
  Future<ProgramSwitchResult> startProgram({
    required Program program,
    required Map<String, int> startingMaxes,
    String? userNotes,
    bool forceSwitch = false,
  }) async {
    final history = await getProgramHistory();
    
    // Check if user can switch programs (only if not forcing the switch)
    if (history.currentProgram != null && !forceSwitch) {
      if (!history.canSwitchPrograms()) {
        return ProgramSwitchResult(
          success: false,
          requiresConfirmation: true,
          warningMessage: 'You just started a program. Switching too early can hurt progress.',
          momentumWarning: history.getMomentumWarning(),
        );
      } else {
        return ProgramSwitchResult(
          success: false,
          requiresConfirmation: true,
          warningMessage: 'You will lose your current progress.',
          momentumWarning: history.getMomentumWarning(),
        );
      }
    }

    // Create new active program
    final activeProgram = ActiveProgram(
      id: '${program.id}_${DateTime.now().millisecondsSinceEpoch}',
      programName: program.name,
      startDate: DateTime.now(),
      startingMaxes: startingMaxes,
      programVersion: program.metadata.version,
      currentWeek: 1,
      currentPhase: program.phases.first.name,
      currentMaxes: Map.from(startingMaxes),
      userNotes: userNotes,
    );

    // Update history
    history.startNewProgram(activeProgram);
    await _saveProgramHistory(history);

    return ProgramSwitchResult(
      success: true,
      activeProgram: activeProgram,
    );
  }

  // Complete current program
  Future<void> completeCurrentProgram({
    required CompletionStatus status,
    required Map<String, int> finalMaxes,
    String? userReview,
    int? rating,
  }) async {
    final history = await getProgramHistory();
    
    if (history.currentProgram == null) {
      throw Exception('No active program to complete');
    }

    final completedProgram = CompletedProgram.fromActive(
      history.currentProgram!,
      status,
      userReview,
    );
    
    // Update final maxes
    completedProgram.finalMaxes.addAll(finalMaxes);
    if (rating != null) {
      completedProgram.rating = rating;
    }

    history.addCompletedProgram(completedProgram);
    await _saveProgramHistory(history);
  }

  // Update current program progress
  Future<void> updateProgramProgress({
    int? currentWeek,
    String? currentPhase,
    Map<String, int>? newMaxes,
    String? workoutCompleted,
    String? userNotes,
  }) async {
    final history = await getProgramHistory();
    
    if (history.currentProgram == null) {
      throw Exception('No active program to update');
    }

    final activeProgram = history.currentProgram!;
    
    activeProgram.updateProgress(
      week: currentWeek,
      phase: currentPhase,
      maxes: newMaxes,
      notes: userNotes,
    );

    if (workoutCompleted != null) {
      activeProgram.completedWorkouts.add(workoutCompleted);
    }

    await _saveProgramHistory(history);
  }

  // Get all completed programs
  Future<List<CompletedProgram>> getCompletedPrograms() async {
    final history = await getProgramHistory();
    return history.completedPrograms;
  }

  // Get strength progression data
  Future<Map<String, StrengthProgression>> getStrengthProgression() async {
    final history = await getProgramHistory();
    return history.getStrengthProgression();
  }

  // Save a program as template
  Future<void> saveAsTemplate({
    required Program program,
    required String templateName,
    Map<String, dynamic> customizations = const {},
  }) async {
    final history = await getProgramHistory();
    
    final template = ProgramTemplate(
      id: '${program.id}_template_${DateTime.now().millisecondsSinceEpoch}',
      name: templateName,
      program: program,
      userCustomizations: customizations,
      createdDate: DateTime.now(),
    );

    history.savedTemplates.add(template);
    await _saveProgramHistory(history);
  }

  // Get saved templates
  Future<List<ProgramTemplate>> getSavedTemplates() async {
    final history = await getProgramHistory();
    return history.savedTemplates;
  }

  // Get program switching recommendations
  Future<ProgramRecommendation> getProgramSwitchRecommendation() async {
    final history = await getProgramHistory();
    
    if (history.currentProgram == null) {
      return ProgramRecommendation(
        canSwitch: true,
        recommendation: RecommendationType.proceed,
        message: 'No active program. You can start a new program anytime.',
      );
    }

    final daysInProgram = history.currentProgram!.getDaysInProgram();
    final weeksInProgram = daysInProgram / 7;

    if (weeksInProgram < 1) {
      return ProgramRecommendation(
        canSwitch: false,
        recommendation: RecommendationType.stronglyDiscourage,
        message: 'You just started this program ${daysInProgram} days ago. Give it at least 2 weeks.',
        momentumLoss: 'High',
      );
    } else if (weeksInProgram < 2) {
      return ProgramRecommendation(
        canSwitch: true,
        recommendation: RecommendationType.discourage,
        message: 'You\'ve been on this program for ${weeksInProgram.round()} week(s). Consider giving it more time.',
        momentumLoss: 'Medium-High',
      );
    } else if (weeksInProgram < 4) {
      return ProgramRecommendation(
        canSwitch: true,
        recommendation: RecommendationType.caution,
        message: 'You\'ve invested ${weeksInProgram.round()} weeks. Switching now means losing built momentum.',
        momentumLoss: 'Medium',
      );
    } else {
      return ProgramRecommendation(
        canSwitch: true,
        recommendation: RecommendationType.proceed,
        message: 'You\'ve given this program a fair chance. If it\'s not working, switching may be beneficial.',
        momentumLoss: 'Low',
      );
    }
  }

  // Private helper to save program history
  Future<void> _saveProgramHistory(ProgramHistory history) async {
    final programHistoryBox = HiveDatabase.userPreferencesBox;
    await programHistoryBox.put(_programHistoryKey, history);
  }

  // Get statistics
  Future<ProgramStatistics> getStatistics() async {
    final history = await getProgramHistory();
    
    return ProgramStatistics(
      totalProgramsCompleted: history.completedPrograms.length,
      totalTrainingTime: history.getTotalTrainingTime(),
      currentStreak: _calculateCurrentStreak(history),
      averageCompletionRate: _calculateAverageCompletionRate(history),
      strengthGains: history.getStrengthProgression(),
    );
  }

  int _calculateCurrentStreak(ProgramHistory history) {
    // Calculate current consecutive program completion streak
    int streak = 0;
    for (int i = history.completedPrograms.length - 1; i >= 0; i--) {
      if (history.completedPrograms[i].status == CompletionStatus.completed) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double _calculateAverageCompletionRate(ProgramHistory history) {
    if (history.completedPrograms.isEmpty) return 0.0;
    
    final completedCount = history.completedPrograms
        .where((p) => p.status == CompletionStatus.completed)
        .length;
    
    return (completedCount / history.completedPrograms.length) * 100;
  }
}

// Supporting classes for service responses
class ProgramSwitchResult {
  final bool success;
  final bool requiresConfirmation;
  final String? warningMessage;
  final String? momentumWarning;
  final ActiveProgram? activeProgram;

  ProgramSwitchResult({
    required this.success,
    this.requiresConfirmation = false,
    this.warningMessage,
    this.momentumWarning,
    this.activeProgram,
  });
}

class ProgramRecommendation {
  final bool canSwitch;
  final RecommendationType recommendation;
  final String message;
  final String? momentumLoss;

  ProgramRecommendation({
    required this.canSwitch,
    required this.recommendation,
    required this.message,
    this.momentumLoss,
  });
}

enum RecommendationType {
  proceed,
  caution,
  discourage,
  stronglyDiscourage,
}

class ProgramStatistics {
  final int totalProgramsCompleted;
  final Duration totalTrainingTime;
  final int currentStreak;
  final double averageCompletionRate;
  final Map<String, StrengthProgression> strengthGains;

  ProgramStatistics({
    required this.totalProgramsCompleted,
    required this.totalTrainingTime,
    required this.currentStreak,
    required this.averageCompletionRate,
    required this.strengthGains,
  });
}