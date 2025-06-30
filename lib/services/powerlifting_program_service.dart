import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../repositories/hive_database.dart';

class PowerliftingProgramService {
  static const String _programActiveKey = 'powerlifting_program_active';
  static const String _currentWeekKey = 'current_week';
  static const String _programStartDateKey = 'program_start_date';

  // Initialize 18-week powerlifting program
  Future<void> initializeProgram(UserProfile userProfile) async {
    final prefs = HiveDatabase.userPreferencesBox;
    
    await prefs.put(_programActiveKey, true);
    await prefs.put(_currentWeekKey, 1);
    await prefs.put(_programStartDateKey, DateTime.now().toIso8601String());
    
    // Generate all 18 weeks of workouts
    await _generateAllWorkouts(userProfile);
  }

  // Check if program is active
  Future<bool> isProgramActive() async {
    final prefs = HiveDatabase.userPreferencesBox;
    return prefs.get(_programActiveKey, defaultValue: false) as bool;
  }

  // Get current week (1-18)
  Future<int> getCurrentWeek() async {
    final prefs = HiveDatabase.userPreferencesBox;
    return prefs.get(_currentWeekKey, defaultValue: 1) as int;
  }

  // Advance to next week
  Future<void> advanceWeek() async {
    final prefs = HiveDatabase.userPreferencesBox;
    int currentWeek = await getCurrentWeek();
    
    if (currentWeek < 18) {
      await prefs.put(_currentWeekKey, currentWeek + 1);
    } else {
      // Program completed
      await prefs.put(_programActiveKey, false);
    }
  }

  // Get workout for specific day and week
  Future<Workout?> getWorkout(int week, String dayName) async {
    // Check if max testing is needed (training maxes are 0)
    final userProfileBox = HiveDatabase.userProfileBox;
    final userProfile = userProfileBox.get('current_user');
    
    if (userProfile != null && week == 1 && dayName == 'monday') {
      final currentMaxes = userProfile.currentMaxes;
      bool needsMaxTesting = (currentMaxes['squat'] ?? 0) == 0 ||
                            (currentMaxes['inclineBench'] ?? 0) == 0 ||
                            (currentMaxes['deadlift'] ?? 0) == 0;
      
      if (needsMaxTesting) {
        return _createMaxTestingWorkout();
      }
    }
    
    final workoutBox = HiveDatabase.workoutBox;
    String workoutId = 'week_${week}_$dayName';
    
    return workoutBox.get(workoutId);
  }

  // Get current week's workouts
  Future<List<Workout>> getCurrentWeekWorkouts() async {
    int currentWeek = await getCurrentWeek();
    List<Workout> workouts = [];
    
    List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    
    for (String day in days) {
      Workout? workout = await getWorkout(currentWeek, day);
      if (workout != null) {
        workouts.add(workout);
      }
    }
    
    return workouts;
  }

  // Generate all 18 weeks of workouts
  Future<void> _generateAllWorkouts(UserProfile userProfile) async {
    final workoutBox = HiveDatabase.workoutBox;
    
    for (int week = 1; week <= 18; week++) {
      String phase = _getPhaseForWeek(week);
      
      // Monday: Squat Focus + Hip Activation
      Workout mondayWorkout = _generateMondayWorkout(week, phase, userProfile);
      await workoutBox.put('week_${week}_monday', mondayWorkout);
      
      // Tuesday: Incline Bench Focus + Upper Back
      Workout tuesdayWorkout = _generateTuesdayWorkout(week, phase, userProfile);
      await workoutBox.put('week_${week}_tuesday', tuesdayWorkout);
      
      // Wednesday: Deadlift Focus + Unilateral Work
      Workout wednesdayWorkout = _generateWednesdayWorkout(week, phase, userProfile);
      await workoutBox.put('week_${week}_wednesday', wednesdayWorkout);
      
      // Thursday: Volume Upper + Correctives
      Workout thursdayWorkout = _generateThursdayWorkout(week, phase, userProfile);
      await workoutBox.put('week_${week}_thursday', thursdayWorkout);
      
      // Friday: Volume Lower + Hip Stability
      Workout fridayWorkout = _generateFridayWorkout(week, phase, userProfile);
      await workoutBox.put('week_${week}_friday', fridayWorkout);
    }
  }

  String _getPhaseForWeek(int week) {
    if (week <= 6) return "Accumulation";
    if (week <= 12) return "Intensification";
    return "Peaking";
  }

  Workout _generateMondayWorkout(int week, String phase, UserProfile userProfile) {
    List<Exercise> exercises = [];
    
    // Hip activation circuit
    exercises.addAll(Workout.getHipActivationCircuit());
    
    // Main squat work based on phase and week
    exercises.addAll(_generateSquatWork(week, phase));
    
    // Accessory work
    exercises.addAll(_generateMondayAccessories(week, phase));
    
    return Workout(
      id: 'week_${week}_monday',
      dayName: 'monday',
      workoutName: 'Squat Focus + Hip Activation',
      weekNumber: week,
      blockPhase: phase,
      exercises: exercises,
      requiresHipActivation: true,
      keyFocusPoints: Workout.generateFocusPoints('monday', week, phase),
      targetRPERange: _getRPERange(week, phase),
      estimatedDuration: _getEstimatedDuration(phase, 'main'),
    ).applyHipLogic(userProfile.hipSide);
  }

  Workout _generateTuesdayWorkout(int week, String phase, UserProfile userProfile) {
    List<Exercise> exercises = [];
    
    // Upper body warm-up
    exercises.add(Exercise(
      name: "Shoulder Circles",
      sets: 2,
      reps: "10 each direction",
      weight: "Bodyweight",
      type: "warmup",
      cues: ["Slow controlled movement", "Full range of motion"],
      isUnilateral: false,
      muscleGroup: "shoulders",
    ));
    
    // Main incline bench work
    exercises.addAll(_generateInclineBenchWork(week, phase));
    
    // Upper back work
    exercises.addAll(_generateTuesdayAccessories(week, phase));
    
    return Workout(
      id: 'week_${week}_tuesday',
      dayName: 'tuesday',
      workoutName: 'Incline Bench Focus + Upper Back',
      weekNumber: week,
      blockPhase: phase,
      exercises: exercises,
      requiresHipActivation: false,
      keyFocusPoints: Workout.generateFocusPoints('tuesday', week, phase),
      targetRPERange: _getRPERange(week, phase),
      estimatedDuration: _getEstimatedDuration(phase, 'upper'),
    );
  }

  Workout _generateWednesdayWorkout(int week, String phase, UserProfile userProfile) {
    List<Exercise> exercises = [];
    
    // Hip circles and activation
    exercises.add(Exercise(
      name: "Hip Circles",
      sets: 2,
      reps: "10 each direction",
      weight: "Bodyweight",
      type: "warmup",
      cues: ["Control the movement", "Feel the hip mobility"],
      isUnilateral: false,
      muscleGroup: "hips",
      requiresHipActivation: true,
    ));
    
    // Main deadlift work
    exercises.addAll(_generateDeadliftWork(week, phase));
    
    // Unilateral work for hip stability
    exercises.addAll(_generateWednesdayAccessories(week, phase));
    
    return Workout(
      id: 'week_${week}_wednesday',
      dayName: 'wednesday',
      workoutName: 'Deadlift Focus + Unilateral Work',
      weekNumber: week,
      blockPhase: phase,
      exercises: exercises,
      requiresHipActivation: true,
      keyFocusPoints: Workout.generateFocusPoints('wednesday', week, phase),
      targetRPERange: _getRPERange(week, phase),
      estimatedDuration: _getEstimatedDuration(phase, 'main'),
    ).applyHipLogic(userProfile.hipSide);
  }

  Workout _generateThursdayWorkout(int week, String phase, UserProfile userProfile) {
    List<Exercise> exercises = [];
    
    // Volume upper body work
    exercises.addAll(_generateThursdayUpperWork(week, phase));
    
    // Corrective exercises
    exercises.addAll(_generateCorrectiveWork(week, phase));
    
    return Workout(
      id: 'week_${week}_thursday',
      dayName: 'thursday',
      workoutName: 'Volume Upper + Correctives',
      weekNumber: week,
      blockPhase: phase,
      exercises: exercises,
      requiresHipActivation: false,
      keyFocusPoints: Workout.generateFocusPoints('thursday', week, phase),
      targetRPERange: _getVolumeRPERange(week, phase),
      estimatedDuration: _getEstimatedDuration(phase, 'volume'),
    );
  }

  Workout _generateFridayWorkout(int week, String phase, UserProfile userProfile) {
    List<Exercise> exercises = [];
    
    // Hip activation
    exercises.addAll(Workout.getHipActivationCircuit());
    
    // Volume lower body work
    exercises.addAll(_generateFridayLowerWork(week, phase));
    
    // Hip stability work
    exercises.addAll(_generateHipStabilityWork(week, phase));
    
    return Workout(
      id: 'week_${week}_friday',
      dayName: 'friday',
      workoutName: 'Volume Lower + Hip Stability',
      weekNumber: week,
      blockPhase: phase,
      exercises: exercises,
      requiresHipActivation: true,
      keyFocusPoints: Workout.generateFocusPoints('friday', week, phase),
      targetRPERange: _getVolumeRPERange(week, phase),
      estimatedDuration: _getEstimatedDuration(phase, 'volume'),
    ).applyHipLogic(userProfile.hipSide);
  }

  // Generate squat work based on week and phase
  List<Exercise> _generateSquatWork(int week, String phase) {
    Map<String, double> intensityRange = UserProfile.getIntensityByWeek(week, phase);
    List<Exercise> exercises = [];
    
    if (week == 6 || week == 12) {
      // Deload weeks
      exercises.add(Exercise(
        name: "Back Squat",
        sets: 3,
        reps: 5,
        weight: "${(intensityRange['max']! * 100).round()}%",
        type: "main",
        cues: ["Focus on technique", "Control the descent", "Drive through heels"],
        isUnilateral: false,
        muscleGroup: "legs",
        equipment: "barbell",
        rpeTarget: "6-7",
      ));
    } else {
      // Progressive loading based on phase
      if (phase == "Accumulation") {
        exercises.addAll([
          Exercise(
            name: "Back Squat",
            sets: 4,
            reps: 8,
            weight: "${(intensityRange['min']! * 100).round()}%",
            type: "main",
            cues: ["Depth to parallel", "Chest up", "Control the tempo"],
            isUnilateral: false,
            muscleGroup: "legs",
            equipment: "barbell",
            rpeTarget: "7-8",
          ),
          Exercise(
            name: "Back Squat",
            sets: 2,
            reps: 6,
            weight: "${(intensityRange['max']! * 100).round()}%",
            type: "main",
            cues: ["Focus on speed out of hole", "Maintain tight core"],
            isUnilateral: false,
            muscleGroup: "legs",
            equipment: "barbell",
            rpeTarget: "8-9",
          ),
        ]);
      } else if (phase == "Intensification") {
        exercises.addAll([
          Exercise(
            name: "Back Squat",
            sets: 5,
            reps: 3,
            weight: "${(intensityRange['min']! * 100).round()}%",
            type: "main",
            cues: ["Maximum tension", "Perfect technique", "Explosive concentric"],
            isUnilateral: false,
            muscleGroup: "legs",
            equipment: "barbell",
            rpeTarget: "8-9",
          ),
          Exercise(
            name: "Back Squat",
            sets: 1,
            reps: 1,
            weight: "${(intensityRange['max']! * 100).round()}%",
            type: "main",
            cues: ["Competition simulation", "Perfect setup"],
            isUnilateral: false,
            muscleGroup: "legs",
            equipment: "barbell",
            rpeTarget: "9-10",
          ),
        ]);
      } else { // Peaking
        exercises.addAll([
          Exercise(
            name: "Back Squat",
            sets: 3,
            reps: 2,
            weight: "${(intensityRange['min']! * 100).round()}%",
            type: "main",
            cues: ["Competition commands", "Perfect technique"],
            isUnilateral: false,
            muscleGroup: "legs",
            equipment: "barbell",
            rpeTarget: "9",
          ),
          Exercise(
            name: "Back Squat",
            sets: 1,
            reps: 1,
            weight: "${(intensityRange['max']! * 100).round()}%",
            type: "main",
            cues: ["Max effort", "Trust your training"],
            isUnilateral: false,
            muscleGroup: "legs",
            equipment: "barbell",
            rpeTarget: "10",
          ),
        ]);
      }
    }
    
    return exercises;
  }

  // Generate incline bench work
  List<Exercise> _generateInclineBenchWork(int week, String phase) {
    Map<String, double> intensityRange = UserProfile.getIntensityByWeek(week, phase);
    List<Exercise> exercises = [];
    
    if (week == 6 || week == 12) {
      exercises.add(Exercise(
        name: "Incline Barbell Bench Press",
        sets: 3,
        reps: 5,
        weight: "${(intensityRange['max']! * 100).round()}%",
        type: "main",
        cues: ["Controlled descent", "Pause at chest", "Drive through feet"],
        isUnilateral: false,
        muscleGroup: "chest",
        equipment: "barbell",
        rpeTarget: "6-7",
      ));
    } else {
      if (phase == "Accumulation") {
        exercises.addAll([
          Exercise(
            name: "Incline Barbell Bench Press",
            sets: 4,
            reps: 6,
            weight: "${(intensityRange['min']! * 100).round()}%",
            type: "main",
            cues: ["Retract shoulder blades", "Control the bar path"],
            isUnilateral: false,
            muscleGroup: "chest",
            equipment: "barbell",
            rpeTarget: "7-8",
          ),
          Exercise(
            name: "Incline Barbell Bench Press",
            sets: 2,
            reps: 4,
            weight: "${(intensityRange['max']! * 100).round()}%",
            type: "main",
            cues: ["Explosive concentric", "Perfect bar path"],
            isUnilateral: false,
            muscleGroup: "chest",
            equipment: "barbell",
            rpeTarget: "8-9",
          ),
        ]);
      }
      // Add similar logic for other phases...
    }
    
    return exercises;
  }

  // Generate deadlift work
  List<Exercise> _generateDeadliftWork(int week, String phase) {
    Map<String, double> intensityRange = UserProfile.getIntensityByWeek(week, phase);
    List<Exercise> exercises = [];
    
    // Similar structure to squat work but for deadlifts
    if (week == 6 || week == 12) {
      exercises.add(Exercise(
        name: "Conventional Deadlift",
        sets: 3,
        reps: 3,
        weight: "${(intensityRange['max']! * 100).round()}%",
        type: "main",
        cues: ["Neutral spine", "Lat engagement", "Hip hinge"],
        isUnilateral: false,
        muscleGroup: "back",
        equipment: "barbell",
        rpeTarget: "6-7",
      ));
    } else {
      // Progressive loading based on phase
      exercises.add(Exercise(
        name: "Conventional Deadlift",
        sets: phase == "Accumulation" ? 5 : phase == "Intensification" ? 4 : 3,
        reps: phase == "Accumulation" ? 5 : phase == "Intensification" ? 3 : 2,
        weight: "${(intensityRange['min']! * 100).round()}%",
        type: "main",
        cues: ["Tight core", "Smooth pull", "Lock out completely"],
        isUnilateral: false,
        muscleGroup: "back",
        equipment: "barbell",
        rpeTarget: phase == "Accumulation" ? "7-8" : phase == "Intensification" ? "8-9" : "9-10",
      ));
    }
    
    return exercises;
  }

  // Generate accessory exercises for each day
  List<Exercise> _generateMondayAccessories(int week, String phase) {
    return [
      Exercise(
        name: "Bulgarian Split Squats",
        sets: 3,
        reps: "12 each",
        weight: "Bodyweight + 20 lbs",
        type: "unilateral",
        cues: ["LEFT LEG FIRST", "Control the descent", "Drive through front heel"],
        isUnilateral: true,
        muscleGroup: "legs",
        equipment: "dumbbell",
      ),
      Exercise(
        name: "Romanian Deadlifts",
        sets: 3,
        reps: 12,
        weight: "60%",
        type: "accessory",
        cues: ["Hip hinge", "Maintain neutral spine", "Feel hamstring stretch"],
        isUnilateral: false,
        muscleGroup: "back",
        equipment: "barbell",
      ),
    ];
  }

  List<Exercise> _generateTuesdayAccessories(int week, String phase) {
    return [
      Exercise(
        name: "Bent Over Rows",
        sets: 4,
        reps: 8,
        weight: "60%",
        type: "accessory",
        cues: ["Retract shoulder blades", "Pull to sternum", "Control the negative"],
        isUnilateral: false,
        muscleGroup: "back",
        equipment: "barbell",
      ),
      Exercise(
        name: "Face Pulls",
        sets: 3,
        reps: 15,
        weight: "Light resistance",
        type: "corrective",
        cues: ["External rotation", "Pull to face level", "Squeeze rear delts"],
        isUnilateral: false,
        muscleGroup: "shoulders",
        equipment: "cable",
      ),
    ];
  }

  List<Exercise> _generateWednesdayAccessories(int week, String phase) {
    return [
      Exercise(
        name: "Single Leg RDL",
        sets: 3,
        reps: "10 each",
        weight: "Light dumbbells",
        type: "unilateral",
        cues: ["LEFT LEG FIRST", "Balance and control", "Hip hinge pattern"],
        isUnilateral: true,
        muscleGroup: "back",
        equipment: "dumbbell",
      ),
      Exercise(
        name: "Lateral Lunges",
        sets: 3,
        reps: "8 each",
        weight: "Bodyweight",
        type: "unilateral",
        cues: ["LEFT LEG FIRST", "Hip mobility", "Control the stretch"],
        isUnilateral: true,
        muscleGroup: "legs",
      ),
    ];
  }

  List<Exercise> _generateThursdayUpperWork(int week, String phase) {
    return [
      Exercise(
        name: "Dumbbell Bench Press",
        sets: 3,
        reps: 10,
        weight: "Moderate dumbbells",
        type: "accessory",
        cues: ["Full range of motion", "Control the weight", "Squeeze at top"],
        isUnilateral: false,
        muscleGroup: "chest",
        equipment: "dumbbell",
      ),
      Exercise(
        name: "Lat Pulldowns",
        sets: 3,
        reps: 12,
        weight: "Moderate resistance",
        type: "accessory",
        cues: ["Pull to chest", "Lean back slightly", "Squeeze lats"],
        isUnilateral: false,
        muscleGroup: "back",
        equipment: "cable",
      ),
    ];
  }

  List<Exercise> _generateCorrectiveWork(int week, String phase) {
    return [
      Exercise(
        name: "Band Pull-Aparts",
        sets: 3,
        reps: 20,
        weight: "Light band",
        type: "corrective",
        cues: ["Squeeze shoulder blades", "Control the resistance", "Full range"],
        isUnilateral: false,
        muscleGroup: "shoulders",
        equipment: "band",
      ),
      Exercise(
        name: "Piriformis Stretch",
        sets: 2,
        reps: "30 seconds each",
        weight: "Bodyweight",
        type: "corrective",
        cues: ["Focus on left side", "Gentle stretch", "Breathe deeply"],
        isUnilateral: true,
        muscleGroup: "hips",
      ),
    ];
  }

  List<Exercise> _generateFridayLowerWork(int week, String phase) {
    return [
      Exercise(
        name: "Front Squats",
        sets: 3,
        reps: 8,
        weight: "50%",
        type: "accessory",
        cues: ["Upright torso", "Elbows high", "Control the depth"],
        isUnilateral: false,
        muscleGroup: "legs",
        equipment: "barbell",
      ),
      Exercise(
        name: "Walking Lunges",
        sets: 3,
        reps: "20 total",
        weight: "Light dumbbells",
        type: "unilateral",
        cues: ["LEFT LEG FIRST", "Step through", "Control each rep"],
        isUnilateral: true,
        muscleGroup: "legs",
        equipment: "dumbbell",
      ),
    ];
  }

  List<Exercise> _generateHipStabilityWork(int week, String phase) {
    return [
      Exercise(
        name: "Single Leg Glute Bridges",
        sets: 3,
        reps: "15 each",
        weight: "Bodyweight",
        type: "corrective",
        cues: ["LEFT LEG FIRST", "Squeeze glutes", "Control the movement"],
        isUnilateral: true,
        muscleGroup: "glutes",
        requiresHipActivation: true,
      ),
      Exercise(
        name: "Calf Raises",
        sets: 2,
        reps: 20,
        weight: "Bodyweight",
        type: "accessory",
        cues: ["Full range of motion", "Control the descent", "Feel the stretch"],
        isUnilateral: false,
        muscleGroup: "calves",
      ),
    ];
  }

  String _getRPERange(int week, String phase) {
    if (week == 6 || week == 12) return "6-7"; // Deload weeks
    
    switch (phase) {
      case "Accumulation":
        return "6-8";
      case "Intensification":
        return "7-9";
      case "Peaking":
        return "8-10";
      default:
        return "7-8";
    }
  }

  String _getVolumeRPERange(int week, String phase) {
    if (week == 6 || week == 12) return "5-6"; // Deload weeks
    
    switch (phase) {
      case "Accumulation":
        return "6-7";
      case "Intensification":
        return "6-8";
      case "Peaking":
        return "7-8";
      default:
        return "6-7";
    }
  }

  int _getEstimatedDuration(String phase, String workoutType) {
    switch (workoutType) {
      case 'main':
        switch (phase) {
          case 'Accumulation':
            return 75;
          case 'Intensification':
            return 90;
          case 'Peaking':
            return 105;
          default:
            return 75;
        }
      case 'upper':
        return 60;
      case 'volume':
        return 45;
      default:
        return 60;
    }
  }

  // Create max testing workout when training maxes are 0
  Workout _createMaxTestingWorkout() {
    return Workout(
      id: 'max_testing_protocol',
      dayName: 'monday',
      workoutName: 'Max Strength Testing Protocol',
      weekNumber: 1,
      blockPhase: 'Max Testing',
      exercises: [
        Exercise(
          name: 'Max Testing Protocol',
          sets: 1,
          reps: 'Complete Protocol',
          weight: 'TBD',
          type: 'main',
          cues: [
            'Tap this exercise to begin the Max Testing Protocol',
            'You will perform guided testing for all three main lifts',
            'The protocol uses RPE-based estimation (no dangerous max attempts)',
            'Your training maxes will be calculated from your best sets',
          ],
          isUnilateral: false,
          muscleGroup: 'full_body',
          equipment: 'barbell',
          restPeriod: 300,
          rpeTarget: '8-9',
          specialInstructions: 'Complete the guided max testing protocol to establish your training maxes for Squat, Incline Bench Press, and Deadlift.',
          requiresHipActivation: false,
        ),
      ],
      requiresHipActivation: false,
      keyFocusPoints: [
        'Complete max testing to establish training maxes',
        'Follow safety protocols throughout',
        'Be honest with RPE ratings for accurate estimates',
        'Take adequate rest between exercises',
      ],
      targetRPERange: '8-9 RPE',
      estimatedDuration: 90,
    );
  }

  // Update training maxes after max testing completion and regenerate workouts
  Future<void> updateTrainingMaxesAndRegenerateWorkouts(Map<String, double> maxTestResults) async {
    final userProfileBox = HiveDatabase.userProfileBox;
    final userProfile = userProfileBox.get('current_user');
    
    if (userProfile != null) {
      // Calculate training maxes (90% of estimated 1RM)
      final squatTM = (maxTestResults['Squat'] ?? 0) * 0.9;
      final inclineBenchTM = (maxTestResults['Incline Bench Press'] ?? 0) * 0.9;
      final deadliftTM = (maxTestResults['Deadlift'] ?? 0) * 0.9;
      
      // Update user profile with new training maxes
      userProfile.currentMaxes = {
        'squat': squatTM.round(),
        'inclineBench': inclineBenchTM.round(),
        'deadlift': deadliftTM.round(),
      };
      
      // Update target maxes based on new training maxes
      userProfile.targetMaxes = {
        'squat': (squatTM * 1.3).round(), // 30% gain target
        'inclineBench': (inclineBenchTM * 1.25).round(), // 25% gain target
        'deadlift': (deadliftTM * 1.4).round(), // 40% gain target
      };
      
      // Save updated profile
      await userProfileBox.put('current_user', userProfile);
      
      // Clear existing workouts and regenerate with new training maxes
      final workoutBox = HiveDatabase.workoutBox;
      await workoutBox.clear();
      
      // Regenerate all workouts with updated training maxes
      await _generateAllWorkouts(userProfile);
    }
  }
}