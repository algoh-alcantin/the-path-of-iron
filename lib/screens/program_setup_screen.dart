import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../services/program_service.dart';
import '../services/powerlifting_program_service.dart';
import '../repositories/training_max_repository.dart';
import '../models/training_max.dart';
import '../models/user_profile.dart';
import '../repositories/hive_database.dart';
import 'max_testing_screen.dart';
import 'package:uuid/uuid.dart';

class ProgramSetupScreen extends StatefulWidget {
  final VoidCallback? onProgramCreated;
  
  const ProgramSetupScreen({super.key, this.onProgramCreated});

  @override
  State<ProgramSetupScreen> createState() => _ProgramSetupScreenState();
}

class _ProgramSetupScreenState extends State<ProgramSetupScreen> {
  int _currentStep = 0;
  final _programService = ProgramService();
  final _powerliftingProgramService = PowerliftingProgramService();
  final _trainingMaxRepository = TrainingMaxRepository();
  final _uuid = const Uuid();
  bool _isCreating = false;
  
  // Training Max Controllers
  final _squatController = TextEditingController();
  final _benchController = TextEditingController();
  final _deadliftController = TextEditingController();
  final _ohpController = TextEditingController();
  
  // Program Settings
  String _selectedProgram = 'Hip-Aware Powerlifting Program';
  String _experienceLevel = 'Intermediate';
  bool _useKilograms = false;
  
  // Hip-specific settings
  bool _hasHipIssues = false;
  String _hipSide = 'left';
  final _nameController = TextEditingController();
  int _trainingExperience = 18; // months
  
  // Max testing results
  Map<String, double> _maxTestResults = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamuraiColors.midnightBlack,
      appBar: AppBar(
        title: Text(
          'FORGE YOUR PATH',
          style: SamuraiTextStyles.katanaSharp(fontSize: 20),
        ),
        backgroundColor: SamuraiColors.midnightBlack,
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 4) {
            // Validate max testing completion for Hip-Aware Powerlifting Program
            if (_currentStep == 1 && _selectedProgram == 'Hip-Aware Powerlifting Program' && _maxTestResults.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please complete the max testing protocol before proceeding',
                    style: SamuraiTextStyles.brushStroke(),
                  ),
                  backgroundColor: SamuraiColors.sanguineRed,
                ),
              );
              return;
            }
            setState(() => _currentStep++);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) => _buildStepControls(details),
        type: StepperType.vertical,
        physics: const ClampingScrollPhysics(),
        steps: [
          Step(
            title: Text(
              'Choose Your Program',
              style: SamuraiTextStyles.brushStroke(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SamuraiColors.ashWhite,
              ),
            ),
            content: _buildProgramSelection(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(
              'Max Testing Protocol',
              style: SamuraiTextStyles.brushStroke(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SamuraiColors.ashWhite,
              ),
            ),
            content: _buildMaxTestingStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : 
                   _currentStep == 1 ? StepState.indexed : StepState.disabled,
          ),
          Step(
            title: Text(
              'Weakness Assessment',
              style: SamuraiTextStyles.brushStroke(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SamuraiColors.ashWhite,
              ),
            ),
            content: _buildWeaknessAssessment(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : 
                   _currentStep == 2 ? StepState.indexed : StepState.disabled,
          ),
          Step(
            title: Text(
              'Configure Preferences',
              style: SamuraiTextStyles.brushStroke(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SamuraiColors.ashWhite,
              ),
            ),
            content: _buildPreferences(),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : 
                   _currentStep == 3 ? StepState.indexed : StepState.disabled,
          ),
          Step(
            title: Text(
              'Begin Your Journey',
              style: SamuraiTextStyles.brushStroke(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SamuraiColors.ashWhite,
              ),
            ),
            content: _buildFinalStep(),
            isActive: _currentStep >= 4,
            state: _currentStep == 4 ? StepState.indexed : StepState.disabled,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Training Program',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 18,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 16),
          ...['Hip-Aware Powerlifting Program', 'UHF 5 Week', 'UHF 9 Week', 'GZCL Method'].map((program) =>
            _buildProgramOption(program),
          ),
          const SizedBox(height: 20),
          Text(
            'Experience Level',
            style: SamuraiTextStyles.brushStroke(
              fontSize: 16,
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 8),
          ...['Beginner', 'Intermediate', 'Advanced'].map((level) =>
            _buildExperienceOption(level),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramOption(String program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        title: Text(
          program,
          style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
        ),
        subtitle: Text(
          _getProgramDescription(program),
          style: SamuraiTextStyles.ancientWisdom(
            color: SamuraiColors.sakuraPink,
          ),
        ),
        value: program,
        groupValue: _selectedProgram,
        onChanged: (value) => setState(() => _selectedProgram = value!),
        activeColor: SamuraiColors.goldenKoi,
      ),
    );
  }

  Widget _buildExperienceOption(String level) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: RadioListTile<String>(
        title: Text(
          level,
          style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
        ),
        value: level,
        groupValue: _experienceLevel,
        onChanged: (value) => setState(() => _experienceLevel = value!),
        activeColor: SamuraiColors.goldenKoi,
      ),
    );
  }

  String _getProgramDescription(String program) {
    switch (program) {
      case 'Hip-Aware Powerlifting Program':
        return '18-week intermediate program with weakness-specific correctives and block periodization';
      case 'UHF 5 Week':
        return 'Intense 5-week block focusing on peak strength';
      case 'UHF 9 Week':
        return 'Extended program with gradual progression';
      case 'GZCL Method':
        return 'Classic GZCL template with T1/T2/T3 structure';
      default:
        return '';
    }
  }

  Widget _buildTrainingMaxInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SamuraiIcons.katana, color: SamuraiColors.goldenKoi),
              const SizedBox(width: 12),
              Text(
                'Training Maxes',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your current 1-rep max or use 90% of your true max',
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.sakuraPink,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Units: ',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
              ),
              Switch(
                value: _useKilograms,
                onChanged: (value) => setState(() => _useKilograms = value),
                activeColor: SamuraiColors.goldenKoi,
              ),
              Text(
                _useKilograms ? 'Kilograms' : 'Pounds',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTrainingMaxField('Squat', _squatController, Icons.fitness_center),
          _buildTrainingMaxField('Bench Press', _benchController, Icons.sports_gymnastics),
          _buildTrainingMaxField('Deadlift', _deadliftController, Icons.sports_kabaddi),
          _buildTrainingMaxField('Overhead Press', _ohpController, Icons.sports_martial_arts),
        ],
      ),
    );
  }

  Widget _buildTrainingMaxField(String exercise, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SamuraiColors.sanguineRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: SamuraiColors.sanguineRed, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise,
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.ashWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: SamuraiTextStyles.katanaSharp(
                    color: SamuraiColors.goldenKoi,
                  ),
                  decoration: InputDecoration(
                    hintText: _useKilograms ? 'kg' : 'lbs',
                    hintStyle: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite.withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SamuraiColors.ironGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SamuraiColors.goldenKoi),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxTestingStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(SamuraiIcons.katana, color: SamuraiColors.goldenKoi),
              const SizedBox(width: 12),
              Text(
                'Guided Max Testing',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Follow a structured protocol to safely determine your training maxes.',
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.sakuraPink,
            ),
          ),
          const SizedBox(height: 24),
          if (_maxTestResults.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SamuraiColors.contemplativeBlue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protocol Overview:',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Guided warmup sequence for each lift\n'
                    '• Progressive working sets with RPE tracking\n'
                    '• Automatic 1RM estimation from your best sets\n'
                    '• Safe 90% training max calculation\n'
                    '• No dangerous true max attempts required',
                    style: SamuraiTextStyles.ancientWisdom(
                      color: SamuraiColors.ashWhite,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SamuraiColors.sanguineRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SamuraiColors.sanguineRed),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, color: SamuraiColors.sanguineRed),
                      const SizedBox(width: 8),
                      Text(
                        'Safety First',
                        style: SamuraiTextStyles.brushStroke(
                          color: SamuraiColors.ashWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure you have:\n'
                    '• Proper warmup completed\n'
                    '• Safety equipment (collars, spotter if needed)\n'
                    '• Familiar with the exercises\n'
                    '• Listen to your body - stop if something feels wrong',
                    style: SamuraiTextStyles.ancientWisdom(
                      color: SamuraiColors.ashWhite,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startMaxTesting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamuraiColors.sanguineRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      SamuraiIcons.katana,
                      color: SamuraiColors.ashWhite,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'BEGIN MAX TESTING',
                      style: SamuraiTextStyles.katanaSharp(
                        fontSize: 16,
                        color: SamuraiColors.ashWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SamuraiColors.honorableGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SamuraiColors.honorableGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: SamuraiColors.honorableGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Max Testing Complete!',
                        style: SamuraiTextStyles.brushStroke(
                          color: SamuraiColors.ashWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your training maxes have been calculated:',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._maxTestResults.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getDisplayName(entry.key),
                          style: SamuraiTextStyles.brushStroke(
                            color: SamuraiColors.ashWhite,
                          ),
                        ),
                        Text(
                          '${(entry.value * 0.9).round()} lbs',
                          style: SamuraiTextStyles.katanaSharp(
                            color: SamuraiColors.honorableGreen,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startMaxTesting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamuraiColors.contemplativeBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'RETEST MAXES',
                  style: SamuraiTextStyles.brushStroke(
                    fontSize: 14,
                    color: SamuraiColors.ashWhite,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _getDisplayName(String exercise) {
    switch (exercise) {
      case 'Incline Bench Press':
        return 'Incline Bench';
      default:
        return exercise;
    }
  }
  
  void _startMaxTesting() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaxTestingScreen(
          onMaxesCalculated: (maxes) {
            setState(() {
              _maxTestResults = maxes;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildWeaknessAssessment() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: SamuraiColors.goldenKoi),
              const SizedBox(width: 12),
              Text(
                'Weakness Assessment',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 18,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This program adapts to your specific weaknesses and imbalances to optimize your training.',
            style: SamuraiTextStyles.ancientWisdom(
              color: SamuraiColors.sakuraPink,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Name:',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: SamuraiTextStyles.katanaSharp(
              color: SamuraiColors.goldenKoi,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: SamuraiTextStyles.brushStroke(
                color: SamuraiColors.ashWhite.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SamuraiColors.ironGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SamuraiColors.goldenKoi),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SamuraiColors.ironGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: SamuraiColors.goldenKoi.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weakness Area (more options coming soon)',
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.ashWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: true, // Currently only hip option available
                        onChanged: (value) {
                          setState(() => _hasHipIssues = true);
                        },
                        activeColor: SamuraiColors.goldenKoi,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.accessibility_new, color: SamuraiColors.contemplativeBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hip Imbalance/Weakness',
                              style: SamuraiTextStyles.brushStroke(
                                color: SamuraiColors.ashWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Currently available - specialized for hip issues',
                              style: SamuraiTextStyles.ancientWisdom(
                                fontSize: 11,
                                color: SamuraiColors.sakuraPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SamuraiColors.ironGray.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: SamuraiColors.ironGray.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: true, // Disabled for now
                        onChanged: null, // Disabled
                        activeColor: SamuraiColors.ironGray,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.more_horiz, color: SamuraiColors.ironGray, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Other Weaknesses',
                              style: SamuraiTextStyles.brushStroke(
                                color: SamuraiColors.ironGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Knee, shoulder, back assessments - coming soon',
                              style: SamuraiTextStyles.ancientWisdom(
                                fontSize: 11,
                                color: SamuraiColors.ironGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_hasHipIssues) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Which side has the weakness/imbalance?',
                    style: SamuraiTextStyles.brushStroke(
                      color: SamuraiColors.ashWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'left',
                        groupValue: _hipSide,
                        onChanged: (value) => setState(() => _hipSide = value!),
                        activeColor: SamuraiColors.goldenKoi,
                      ),
                      Text(
                        'Left',
                        style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
                      ),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: 'right',
                        groupValue: _hipSide,
                        onChanged: (value) => setState(() => _hipSide = value!),
                        activeColor: SamuraiColors.goldenKoi,
                      ),
                      Text(
                        'Right',
                        style: SamuraiTextStyles.brushStroke(color: SamuraiColors.ashWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SamuraiColors.sakuraPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'The program will prioritize your $_hipSide side for all unilateral exercises and include targeted corrective work.',
                      style: SamuraiTextStyles.ancientWisdom(
                        color: SamuraiColors.sakuraPink,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Training Experience: $_trainingExperience months',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _trainingExperience.toDouble(),
            min: 6,
            max: 60,
            divisions: 54,
            activeColor: SamuraiColors.goldenKoi,
            inactiveColor: SamuraiColors.ironGray,
            onChanged: (value) => setState(() => _trainingExperience = value.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forge Your Preferences',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 18,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreferenceItem(
            'Auto-progression',
            'Automatically increase training maxes based on AMRAP performance',
            true,
          ),
          _buildPreferenceItem(
            'Rest Timer',
            'Show rest periods between sets',
            true,
          ),
          _buildPreferenceItem(
            'Warm-up Sets',
            'Generate warm-up recommendations',
            true,
          ),
          _buildPreferenceItem(
            'Recovery Tracking',
            'Monitor subjective wellness markers',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(String title, String description, bool initialValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SamuraiColors.goldenKoi.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SamuraiTextStyles.brushStroke(
                    color: SamuraiColors.ashWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: SamuraiTextStyles.ancientWisdom(
                    color: SamuraiColors.sakuraPink,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: (value) {},
            activeColor: SamuraiColors.goldenKoi,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SamuraiDecorations.forgeContainer,
      child: Column(
        children: [
          const Icon(
            SamuraiIcons.torii,
            color: SamuraiColors.goldenKoi,
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            'Your Path Awaits',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 24,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"The journey of a thousand miles begins with a single step."',
            style: SamuraiTextStyles.ancientWisdom(
              fontSize: 16,
              color: SamuraiColors.sakuraPink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Your training program has been configured. Begin your journey to strength mastery.',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createProgram,
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.sanguineRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCreating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(SamuraiColors.ashWhite),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'FORGING...',
                          style: SamuraiTextStyles.katanaSharp(
                            fontSize: 16,
                            color: SamuraiColors.ashWhite,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'FORGE THE PATH',
                      style: SamuraiTextStyles.katanaSharp(
                        fontSize: 16,
                        color: SamuraiColors.ashWhite,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepControls(ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (details.stepIndex > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: Text(
                'BACK',
                style: SamuraiTextStyles.brushStroke(
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ),
          const SizedBox(width: 12),
          if (details.stepIndex < 4)
            ElevatedButton(
              onPressed: details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.goldenKoi,
                foregroundColor: SamuraiColors.midnightBlack,
              ),
              child: Text(
                'CONTINUE',
                style: SamuraiTextStyles.brushStroke(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _createProgram() async {
    if (_isCreating) return;
    
    setState(() => _isCreating = true);
    
    try {
      // Validate inputs
      if (_nameController.text.isEmpty) {
        throw Exception('Please enter your name');
      }
      
      if (_selectedProgram == 'Hip-Aware Powerlifting Program' && _maxTestResults.isEmpty) {
        throw Exception('Please complete the max testing protocol');
      }

      if (_selectedProgram == 'Hip-Aware Powerlifting Program') {
        // Calculate training maxes from max testing results (90% of estimated 1RM)
        final squatTM = (_maxTestResults['Squat'] ?? 0) * 0.9;
        final inclineBenchTM = (_maxTestResults['Incline Bench Press'] ?? 0) * 0.9;
        final deadliftTM = (_maxTestResults['Deadlift'] ?? 0) * 0.9;
        
        // Create UserProfile for the new powerlifting program
        final userProfile = UserProfile(
          name: _nameController.text,
          currentWeek: 1,
          currentBlock: "Accumulation",
          currentMaxes: {
            'squat': squatTM.round(),
            'inclineBench': inclineBenchTM.round(),
            'deadlift': deadliftTM.round(),
          },
          targetMaxes: {
            'squat': (squatTM * 1.3).round(), // 30% gain target
            'inclineBench': (inclineBenchTM * 1.25).round(), // 25% gain target
            'deadlift': (deadliftTM * 1.4).round(), // 40% gain target
          },
          hipIssues: _hasHipIssues,
          hipSide: _hipSide,
          programStartDate: DateTime.now(),
          completedWorkouts: [],
          trainingExperience: _trainingExperience,
          experienceLevel: _experienceLevel,
          trainingFrequency: 5, // 5 days per week
        );

        // Save user profile
        final userProfileBox = HiveDatabase.userProfileBox;
        await userProfileBox.put('current_user', userProfile);

        // Initialize the 18-week powerlifting program
        await _powerliftingProgramService.initializeProgram(userProfile);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Weakness-Aware Powerlifting Program created! Your 18-week journey begins now.',
                style: SamuraiTextStyles.brushStroke(),
              ),
              backgroundColor: SamuraiColors.honorableGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Original program creation logic for other programs
        // Parse training maxes from text controllers
        final squatTM = double.tryParse(_squatController.text) ?? 0;
        final benchTM = double.tryParse(_benchController.text) ?? 0;
        final deadliftTM = double.tryParse(_deadliftController.text) ?? 0;
        final ohpTM = double.tryParse(_ohpController.text) ?? 0;
        
        // Validate that all maxes are entered
        if (squatTM <= 0 || benchTM <= 0 || deadliftTM <= 0 || ohpTM <= 0) {
          throw Exception('Please enter valid training maxes for all exercises');
        }
        
        final now = DateTime.now();
        final trainingMaxes = [
          TrainingMax(
            id: _uuid.v4(),
            exercise: 'Squat',
            weight: squatTM,
            lastTested: now,
          ),
          TrainingMax(
            id: _uuid.v4(),
            exercise: 'Bench Press',
            weight: benchTM,
            lastTested: now,
          ),
          TrainingMax(
            id: _uuid.v4(),
            exercise: 'Deadlift',
            weight: deadliftTM,
            lastTested: now,
          ),
          TrainingMax(
            id: _uuid.v4(),
            exercise: 'Overhead Press',
            weight: ohpTM,
            lastTested: now,
          ),
        ];
        
        // Save training maxes to database
        for (final tm in trainingMaxes) {
          await _trainingMaxRepository.saveTrainingMax(tm);
        }
        
        // Create and save program
        final programId = _uuid.v4();
        await _programService.setActiveProgram(programId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Program forged successfully! Your path to strength begins now.',
                style: SamuraiTextStyles.brushStroke(),
              ),
              backgroundColor: SamuraiColors.honorableGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      
      // Trigger callback and navigate back after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onProgramCreated?.call();
        }
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating program: ${e.toString()}',
              style: SamuraiTextStyles.brushStroke(),
            ),
            backgroundColor: SamuraiColors.shamefulRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  void dispose() {
    _squatController.dispose();
    _benchController.dispose();
    _deadliftController.dispose();
    _ohpController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}