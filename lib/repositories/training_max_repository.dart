import 'package:uuid/uuid.dart';
import '../models/training_max.dart';
import 'hive_database.dart';

class TrainingMaxRepository {
  static const Uuid _uuid = Uuid();

  Future<List<TrainingMax>> getAllTrainingMaxes() async {
    final box = HiveDatabase.trainingMaxBox;
    return box.values.where((tm) => tm.isActive).toList();
  }

  Future<TrainingMax?> getTrainingMaxById(String id) async {
    final box = HiveDatabase.trainingMaxBox;
    return box.get(id);
  }

  Future<TrainingMax?> getTrainingMaxByExercise(String exercise) async {
    final box = HiveDatabase.trainingMaxBox;
    return box.values
        .where((tm) => tm.exercise == exercise && tm.isActive)
        .firstOrNull;
  }

  Future<String> saveTrainingMax(TrainingMax trainingMax) async {
    final box = HiveDatabase.trainingMaxBox;
    final id = trainingMax.id.isEmpty ? _uuid.v4() : trainingMax.id;
    final updatedTrainingMax = trainingMax.copyWith(id: id);
    
    await box.put(id, updatedTrainingMax);
    return id;
  }

  Future<void> updateTrainingMax(TrainingMax trainingMax) async {
    final box = HiveDatabase.trainingMaxBox;
    await box.put(trainingMax.id, trainingMax);
  }

  Future<void> deleteTrainingMax(String id) async {
    final box = HiveDatabase.trainingMaxBox;
    final trainingMax = box.get(id);
    if (trainingMax != null) {
      final deactivated = trainingMax.copyWith(isActive: false);
      await box.put(id, deactivated);
    }
  }

  Future<void> addAMRAPResult(String trainingMaxId, AMRAPResult result) async {
    final box = HiveDatabase.trainingMaxBox;
    final trainingMax = box.get(trainingMaxId);
    
    if (trainingMax != null) {
      final updatedResults = List<AMRAPResult>.from(trainingMax.recentResults)
        ..add(result);
      
      if (updatedResults.length > 10) {
        updatedResults.removeAt(0);
      }
      
      final updatedTrainingMax = trainingMax.copyWith(
        recentResults: updatedResults,
        lastTested: result.date,
      );
      
      await box.put(trainingMaxId, updatedTrainingMax);
    }
  }

  Future<double> calculateNewTrainingMax(
    String trainingMaxId, 
    AMRAPResult amrapResult
  ) async {
    final trainingMax = await getTrainingMaxById(trainingMaxId);
    if (trainingMax == null) return 0.0;

    final estimatedMax = amrapResult.estimatedOneRepMax;
    final progressionRate = _getProgressionRate(trainingMax.exercise);
    const conservativeFactor = 0.90;
    
    final newMax = (trainingMax.weight * (1 + progressionRate))
        .clamp(0.0, estimatedMax * conservativeFactor);
    
    return newMax.toDouble();
  }

  double _getProgressionRate(String exercise) {
    const Map<String, double> progressionRates = {
      'squat': 0.025,
      'bench_press': 0.0125,
      'deadlift': 0.025,
      'overhead_press': 0.0125,
    };
    
    final normalizedExercise = exercise.toLowerCase().replaceAll(' ', '_');
    return progressionRates[normalizedExercise] ?? 0.02;
  }

  Future<List<TrainingMax>> getTrainingMaxesForExercises(List<String> exercises) async {
    final box = HiveDatabase.trainingMaxBox;
    return box.values
        .where((tm) => exercises.contains(tm.exercise) && tm.isActive)
        .toList();
  }

  Future<bool> hasTrainingMaxForExercise(String exercise) async {
    final trainingMax = await getTrainingMaxByExercise(exercise);
    return trainingMax != null;
  }
}