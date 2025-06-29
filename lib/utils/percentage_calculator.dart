import '../models/training_max.dart';
import '../models/progression_scheme.dart';

class PercentageCalculator {
  static double calculateWeight(TrainingMax trainingMax, double percentage) {
    return trainingMax.getTrainingMaxPercentage(percentage);
  }

  static double calculatePercentageFromWeight(TrainingMax trainingMax, double weight) {
    if (trainingMax.weight == 0) return 0.0;
    return (weight / trainingMax.weight) * 100;
  }

  static double roundToNearestPlate(double weight, {double plateIncrement = 2.5}) {
    return (weight / plateIncrement).round() * plateIncrement;
  }

  static List<double> calculateWorkingWeights(
    TrainingMax trainingMax,
    List<SetProgression> setProgressions,
    {double intensityModifier = 1.0}
  ) {
    return setProgressions.map((progression) {
      final baseWeight = calculateWeight(trainingMax, progression.percentage);
      final modifiedWeight = baseWeight * intensityModifier;
      return roundToNearestPlate(modifiedWeight);
    }).toList();
  }

  static double calculateWarmupWeight(TrainingMax trainingMax, double workingPercentage) {
    if (workingPercentage <= 50) return 0.0;
    
    final warmupPercentage = (workingPercentage * 0.6).clamp(40.0, 60.0);
    
    return roundToNearestPlate(calculateWeight(trainingMax, warmupPercentage));
  }

  static List<WarmupSet> generateWarmupProgression(
    TrainingMax trainingMax,
    double workingPercentage
  ) {
    final List<WarmupSet> warmupSets = [];
    
    if (workingPercentage <= 40) return warmupSets;
    
    final workingWeight = calculateWeight(trainingMax, workingPercentage);
    
    warmupSets.add(WarmupSet(
      weight: 0.0,
      reps: 10,
      description: 'Empty bar or light warm-up',
    ));
    
    if (workingPercentage > 50) {
      warmupSets.add(WarmupSet(
        weight: roundToNearestPlate(workingWeight * 0.4),
        reps: 8,
        description: '40% warm-up',
      ));
    }
    
    if (workingPercentage > 60) {
      warmupSets.add(WarmupSet(
        weight: roundToNearestPlate(workingWeight * 0.6),
        reps: 5,
        description: '60% warm-up',
      ));
    }
    
    if (workingPercentage > 80) {
      warmupSets.add(WarmupSet(
        weight: roundToNearestPlate(workingWeight * 0.8),
        reps: 3,
        description: '80% opener',
      ));
    }
    
    return warmupSets;
  }

  static double calculateDeloadWeight(TrainingMax trainingMax, double percentage) {
    const deloadFactor = 0.6;
    final baseWeight = calculateWeight(trainingMax, percentage);
    return roundToNearestPlate(baseWeight * deloadFactor);
  }

  static double calculateEstimatedOneRepMax(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (1 + 0.0333 * reps);
  }

  static double calculateRecommendedTrainingMax(double oneRepMax) {
    return oneRepMax * 0.85;
  }

  static Map<String, double> calculatePlateLoadout(double targetWeight, {double barWeight = 45.0}) {
    final plateWeight = targetWeight - barWeight;
    if (plateWeight <= 0) return {'bar_only': targetWeight};
    
    final Map<String, double> availablePlates = {
      '45': 45.0,
      '35': 35.0,
      '25': 25.0,
      '10': 10.0,
      '5': 5.0,
      '2.5': 2.5,
    };
    
    final Map<String, double> plateLoadout = {};
    double remainingWeight = plateWeight / 2;
    
    for (final entry in availablePlates.entries) {
      final plateValue = entry.value;
      final plateCount = (remainingWeight / plateValue).floor();
      
      if (plateCount > 0) {
        plateLoadout[entry.key] = plateCount.toDouble();
        remainingWeight -= plateCount * plateValue;
      }
    }
    
    return plateLoadout;
  }
}

class WarmupSet {
  final double weight;
  final int reps;
  final String description;

  const WarmupSet({
    required this.weight,
    required this.reps,
    required this.description,
  });
}