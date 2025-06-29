import 'package:hive_flutter/hive_flutter.dart';
import '../models/training_max.dart';
import '../models/workout_session.dart';
import '../models/progression_scheme.dart';

class HiveDatabase {
  static const String _trainingMaxBoxName = 'training_maxes';
  static const String _workoutSessionBoxName = 'workout_sessions';
  static const String _progressionSchemeBoxName = 'progression_schemes';
  static const String _userPreferencesBoxName = 'user_preferences';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(TrainingMaxAdapter());
    Hive.registerAdapter(AMRAPResultAdapter());
    Hive.registerAdapter(WorkoutSessionAdapter());
    Hive.registerAdapter(ExerciseSetAdapter());
    Hive.registerAdapter(TierTypeAdapter());
    Hive.registerAdapter(SubjectiveMarkersAdapter());
    Hive.registerAdapter(ProgressionSchemeAdapter());
    Hive.registerAdapter(WeeklyProgressionAdapter());
    Hive.registerAdapter(DailyProgressionAdapter());
    Hive.registerAdapter(SetProgressionAdapter());
    Hive.registerAdapter(RepSchemeAdapter());
    Hive.registerAdapter(AutoregulationRulesAdapter());
    
    await Hive.openBox<TrainingMax>(_trainingMaxBoxName);
    await Hive.openBox<WorkoutSession>(_workoutSessionBoxName);
    await Hive.openBox<ProgressionScheme>(_progressionSchemeBoxName);
    await Hive.openBox(_userPreferencesBoxName);
  }

  static Box<TrainingMax> get trainingMaxBox => 
      Hive.box<TrainingMax>(_trainingMaxBoxName);

  static Box<WorkoutSession> get workoutSessionBox => 
      Hive.box<WorkoutSession>(_workoutSessionBoxName);

  static Box<ProgressionScheme> get progressionSchemeBox => 
      Hive.box<ProgressionScheme>(_progressionSchemeBoxName);

  static Box get userPreferencesBox => 
      Hive.box(_userPreferencesBoxName);

  static Future<void> close() async {
    await Hive.close();
  }

  static Future<void> clearAllData() async {
    await trainingMaxBox.clear();
    await workoutSessionBox.clear();
    await progressionSchemeBox.clear();
    await userPreferencesBox.clear();
  }
}