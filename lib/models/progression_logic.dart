import 'package:hive/hive.dart';

part 'progression_logic.g.dart';

@HiveType(typeId: 28)
class ProgressionLogic extends HiveObject {
  @HiveField(0)
  ProgressionType type;

  @HiveField(1)
  Map<String, dynamic> parameters;

  @HiveField(2)
  List<ProgressionRule> rules;

  @HiveField(3)
  Map<String, AutoregulationRule> autoregulationRules;

  ProgressionLogic({
    required this.type,
    this.parameters = const {},
    this.rules = const [],
    this.autoregulationRules = const {},
  });

  // Apply progression to a specific exercise
  Map<String, dynamic> calculateProgression({
    required String exerciseName,
    required int currentWeek,
    required int currentPhase,
    required Map<String, int> userMaxes,
    Map<String, dynamic> performanceData = const {},
  }) {
    final rule = _getRuleForExercise(exerciseName);
    if (rule == null) return {};

    return rule.calculateProgression(
      currentWeek: currentWeek,
      currentPhase: currentPhase,
      userMaxes: userMaxes,
      performanceData: performanceData,
    );
  }

  ProgressionRule? _getRuleForExercise(String exerciseName) {
    return rules.firstWhere(
      (rule) => rule.appliesToExercise(exerciseName),
      orElse: () => rules.first,
    );
  }

  // Check if progression should be modified based on performance
  bool shouldAdjustProgression({
    required String exerciseName,
    required Map<String, dynamic> recentPerformance,
  }) {
    final autoRule = autoregulationRules[exerciseName];
    return autoRule?.shouldAdjust(recentPerformance) ?? false;
  }
}

@HiveType(typeId: 29)
enum ProgressionType {
  @HiveField(0)
  linear,
  @HiveField(1)
  periodized,
  @HiveField(2)
  autoregulated,
  @HiveField(3)
  undulating,
  @HiveField(4)
  block,
}

@HiveType(typeId: 30)
class ProgressionRule extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> applicableExercises;

  @HiveField(3)
  ProgressionFormula formula;

  @HiveField(4)
  Map<String, dynamic> parameters;

  ProgressionRule({
    required this.id,
    required this.name,
    required this.applicableExercises,
    required this.formula,
    this.parameters = const {},
  });

  bool appliesToExercise(String exerciseName) {
    return applicableExercises.any((pattern) => 
      exerciseName.toLowerCase().contains(pattern.toLowerCase()));
  }

  Map<String, dynamic> calculateProgression({
    required int currentWeek,
    required int currentPhase,
    required Map<String, int> userMaxes,
    Map<String, dynamic> performanceData = const {},
  }) {
    return formula.calculate(
      currentWeek: currentWeek,
      currentPhase: currentPhase,
      userMaxes: userMaxes,
      performanceData: performanceData,
      parameters: parameters,
    );
  }
}

@HiveType(typeId: 31)
class ProgressionFormula extends HiveObject {
  @HiveField(0)
  FormulaType type;

  @HiveField(1)
  String expression;

  @HiveField(2)
  Map<String, dynamic> constants;

  ProgressionFormula({
    required this.type,
    required this.expression,
    this.constants = const {},
  });

  Map<String, dynamic> calculate({
    required int currentWeek,
    required int currentPhase,
    required Map<String, int> userMaxes,
    Map<String, dynamic> performanceData = const {},
    Map<String, dynamic> parameters = const {},
  }) {
    switch (type) {
      case FormulaType.percentage:
        return _calculatePercentage(currentWeek, userMaxes);
      case FormulaType.linear:
        return _calculateLinear(currentWeek, parameters);
      case FormulaType.exponential:
        return _calculateExponential(currentWeek, parameters);
      case FormulaType.custom:
        return _evaluateCustomFormula(expression, {
          'week': currentWeek,
          'phase': currentPhase,
          'maxes': userMaxes,
          'performance': performanceData,
          ...constants,
          ...parameters,
        });
    }
  }

  Map<String, dynamic> _calculatePercentage(int week, Map<String, int> maxes) {
    // Simple percentage-based progression
    final basePercentage = constants['basePercentage'] ?? 0.8;
    final weeklyIncrease = constants['weeklyIncrease'] ?? 0.025;
    
    final percentage = basePercentage + (week - 1) * weeklyIncrease;
    
    return {
      'percentage': percentage,
      'calculatedWeights': maxes.map((lift, max) => 
        MapEntry(lift, (max * percentage).round())),
    };
  }

  Map<String, dynamic> _calculateLinear(int week, Map<String, dynamic> params) {
    final baseWeight = params['baseWeight'] ?? 100;
    final weeklyIncrease = params['weeklyIncrease'] ?? 5;
    
    return {
      'weight': baseWeight + (week - 1) * weeklyIncrease,
    };
  }

  Map<String, dynamic> _calculateExponential(int week, Map<String, dynamic> params) {
    // Placeholder for exponential progression
    return _calculateLinear(week, params);
  }

  Map<String, dynamic> _evaluateCustomFormula(String formula, Map<String, dynamic> variables) {
    // Placeholder for custom formula evaluation
    // In a real implementation, you'd use an expression parser
    return {};
  }
}

@HiveType(typeId: 32)
enum FormulaType {
  @HiveField(0)
  percentage,
  @HiveField(1)
  linear,
  @HiveField(2)
  exponential,
  @HiveField(3)
  custom,
}

@HiveType(typeId: 33)
class AutoregulationRule extends HiveObject {
  @HiveField(0)
  String trigger;

  @HiveField(1)
  Map<String, dynamic> conditions;

  @HiveField(2)
  Map<String, dynamic> adjustments;

  AutoregulationRule({
    required this.trigger,
    required this.conditions,
    required this.adjustments,
  });

  bool shouldAdjust(Map<String, dynamic> performanceData) {
    // Check if conditions are met for adjustment
    for (final condition in conditions.entries) {
      final value = performanceData[condition.key];
      if (value == null) return false;
      
      // Simple condition checking (can be expanded)
      if (!_evaluateCondition(value, condition.value)) {
        return false;
      }
    }
    return true;
  }

  bool _evaluateCondition(dynamic actual, dynamic expected) {
    // Simple condition evaluation
    if (expected is Map) {
      final operator = expected['operator'] ?? '==';
      final value = expected['value'];
      
      switch (operator) {
        case '>':
          return (actual as num) > (value as num);
        case '<':
          return (actual as num) < (value as num);
        case '>=':
          return (actual as num) >= (value as num);
        case '<=':
          return (actual as num) <= (value as num);
        case '==':
          return actual == value;
        default:
          return false;
      }
    }
    return actual == expected;
  }
}