import 'package:uuid/uuid.dart';
import '../models/workout_session.dart';
import 'hive_database.dart';

class WorkoutSessionRepository {
  static const Uuid _uuid = Uuid();

  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    final box = HiveDatabase.workoutSessionBox;
    final sessions = box.values.toList();
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  Future<WorkoutSession?> getWorkoutSessionById(String id) async {
    final box = HiveDatabase.workoutSessionBox;
    return box.get(id);
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    final box = HiveDatabase.workoutSessionBox;
    return box.values
        .where((session) => 
            session.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            session.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByWeek(int weekNumber) async {
    final box = HiveDatabase.workoutSessionBox;
    return box.values
        .where((session) => session.weekNumber == weekNumber)
        .toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  Future<WorkoutSession?> getWorkoutSessionByWeekAndDay(
    int weekNumber, 
    int dayNumber
  ) async {
    final box = HiveDatabase.workoutSessionBox;
    return box.values
        .where((session) => 
            session.weekNumber == weekNumber && 
            session.dayNumber == dayNumber)
        .firstOrNull;
  }

  Future<String> saveWorkoutSession(WorkoutSession session) async {
    final box = HiveDatabase.workoutSessionBox;
    final id = session.id.isEmpty ? _uuid.v4() : session.id;
    final updatedSession = session.copyWith(id: id);
    
    await box.put(id, updatedSession);
    return id;
  }

  Future<void> updateWorkoutSession(WorkoutSession session) async {
    final box = HiveDatabase.workoutSessionBox;
    await box.put(session.id, session);
  }

  Future<void> deleteWorkoutSession(String id) async {
    final box = HiveDatabase.workoutSessionBox;
    await box.delete(id);
  }

  Future<List<WorkoutSession>> getCompletedWorkoutSessions() async {
    final box = HiveDatabase.workoutSessionBox;
    return box.values
        .where((session) => session.isCompleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<WorkoutSession?> getLastCompletedWorkoutSession() async {
    final completedSessions = await getCompletedWorkoutSessions();
    return completedSessions.isNotEmpty ? completedSessions.first : null;
  }

  Future<double> getTotalVolumeForDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    final sessions = await getWorkoutSessionsByDateRange(startDate, endDate);
    double totalVolume = 0.0;
    for (final session in sessions.where((s) => s.isCompleted)) {
      totalVolume += session.totalVolumeLoad;
    }
    return totalVolume;
  }

  Future<Map<String, double>> getVolumeByExerciseForDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    final sessions = await getWorkoutSessionsByDateRange(startDate, endDate);
    final Map<String, double> volumeByExercise = {};
    
    for (final session in sessions.where((s) => s.isCompleted)) {
      for (final set in session.sets.where((s) => s.isCompleted)) {
        volumeByExercise[set.exercise] = 
            (volumeByExercise[set.exercise] ?? 0.0) + set.volumeLoad;
      }
    }
    
    return volumeByExercise;
  }

  Future<List<ExerciseSet>> getAllSetsForExercise(String exercise) async {
    final box = HiveDatabase.workoutSessionBox;
    final List<ExerciseSet> allSets = [];
    
    for (final session in box.values.where((s) => s.isCompleted)) {
      final exerciseSets = session.sets
          .where((set) => set.exercise == exercise && set.isCompleted);
      allSets.addAll(exerciseSets);
    }
    
    allSets.sort((a, b) => b.id.compareTo(a.id));
    return allSets;
  }

  Future<double> getAverageRecoveryScore(DateTime startDate, DateTime endDate) async {
    final sessions = await getWorkoutSessionsByDateRange(startDate, endDate);
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    
    if (completedSessions.isEmpty) return 0.0;
    
    final totalRecoveryScore = completedSessions
        .fold(0.0, (total, session) => total + session.subjectiveMarkers.recoveryScore);
    
    return totalRecoveryScore / completedSessions.length;
  }
}