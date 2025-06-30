import 'package:hive_flutter/hive_flutter.dart';
import '../models/training_max.dart';
import '../models/workout_session.dart';
import '../models/progression_scheme.dart';
import '../models/user_profile.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_log.dart';

class HiveDatabase {
  static const String _trainingMaxBoxName = 'training_maxes';
  static const String _workoutSessionBoxName = 'workout_sessions';
  static const String _progressionSchemeBoxName = 'progression_schemes';
  static const String _userProfileBoxName = 'user_profiles';
  static const String _exerciseBoxName = 'exercises';
  static const String _workoutBoxName = 'workouts';
  static const String _workoutLogBoxName = 'workout_logs';
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
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(WorkoutLogAdapter());
    Hive.registerAdapter(WorkoutSetAdapter());
    
    await Hive.openBox<TrainingMax>(_trainingMaxBoxName);
    await Hive.openBox<WorkoutSession>(_workoutSessionBoxName);
    await Hive.openBox<ProgressionScheme>(_progressionSchemeBoxName);
    await Hive.openBox<UserProfile>(_userProfileBoxName);
    await Hive.openBox<Exercise>(_exerciseBoxName);
    await Hive.openBox<Workout>(_workoutBoxName);
    await Hive.openBox<WorkoutLog>(_workoutLogBoxName);
    await Hive.openBox(_userPreferencesBoxName);
  }

  static Box<TrainingMax> get trainingMaxBox => 
      Hive.box<TrainingMax>(_trainingMaxBoxName);

  static Box<WorkoutSession> get workoutSessionBox => 
      Hive.box<WorkoutSession>(_workoutSessionBoxName);

  static Box<ProgressionScheme> get progressionSchemeBox => 
      Hive.box<ProgressionScheme>(_progressionSchemeBoxName);

  static Box<UserProfile> get userProfileBox => 
      Hive.box<UserProfile>(_userProfileBoxName);

  static Box<Exercise> get exerciseBox => 
      Hive.box<Exercise>(_exerciseBoxName);

  static Box<Workout> get workoutBox => 
      Hive.box<Workout>(_workoutBoxName);

  static Box<WorkoutLog> get workoutLogBox => 
      Hive.box<WorkoutLog>(_workoutLogBoxName);

  static Box get userPreferencesBox => 
      Hive.box(_userPreferencesBoxName);

  static Future<void> close() async {
    await Hive.close();
  }

  static Future<void> clearAllData() async {
    await trainingMaxBox.clear();
    await workoutSessionBox.clear();
    await progressionSchemeBox.clear();
    await userProfileBox.clear();
    await exerciseBox.clear();
    await workoutBox.clear();
    await workoutLogBox.clear();
    await userPreferencesBox.clear();
  }
}