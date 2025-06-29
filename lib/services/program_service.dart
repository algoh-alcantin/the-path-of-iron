import '../repositories/hive_database.dart';

class ProgramService {
  static const String _hasActiveProgram = 'has_active_program';
  static const String _currentProgramId = 'current_program_id';
  
  Future<bool> hasActiveProgram() async {
    try {
      final prefs = HiveDatabase.userPreferencesBox;
      return prefs.get(_hasActiveProgram, defaultValue: false) as bool;
    } catch (e) {
      print('Error checking active program: $e');
      return false;
    }
  }
  
  Future<void> setActiveProgram(String programId) async {
    try {
      final prefs = HiveDatabase.userPreferencesBox;
      await prefs.put(_hasActiveProgram, true);
      await prefs.put(_currentProgramId, programId);
    } catch (e) {
      print('Error setting active program: $e');
      rethrow;
    }
  }
  
  Future<String?> getCurrentProgramId() async {
    final prefs = HiveDatabase.userPreferencesBox;
    return prefs.get(_currentProgramId) as String?;
  }
  
  Future<void> clearActiveProgram() async {
    final prefs = HiveDatabase.userPreferencesBox;
    await prefs.put(_hasActiveProgram, false);
    await prefs.delete(_currentProgramId);
  }
  
  Future<bool> hasTrainingMaxes() async {
    final tmBox = HiveDatabase.trainingMaxBox;
    return tmBox.values.where((tm) => tm.isActive).isNotEmpty;
  }
  
  Future<int> getCompletedWorkoutsCount() async {
    final workoutBox = HiveDatabase.workoutSessionBox;
    return workoutBox.values.where((session) => session.isCompleted).length;
  }
}