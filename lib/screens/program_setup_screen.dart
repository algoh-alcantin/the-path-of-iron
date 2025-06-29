import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../services/program_service.dart';
import '../repositories/training_max_repository.dart';
import '../models/training_max.dart';
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
  final _trainingMaxRepository = TrainingMaxRepository();
  final _uuid = const Uuid();
  bool _isCreating = false;
  
  // Training Max Controllers
  final _squatController = TextEditingController();
  final _benchController = TextEditingController();
  final _deadliftController = TextEditingController();
  final _ohpController = TextEditingController();
  
  // Program Settings
  String _selectedProgram = 'UHF 5 Week';
  String _experienceLevel = 'Intermediate';
  bool _useKilograms = false;

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
              'Set Training Maxes',
              style: SamuraiTextStyles.brushStroke(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SamuraiColors.ashWhite,
              ),
            ),
            content: _buildTrainingMaxInput(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : 
                   _currentStep == 1 ? StepState.indexed : StepState.disabled,
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
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : 
                   _currentStep == 2 ? StepState.indexed : StepState.disabled,
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
            isActive: _currentStep >= 3,
            state: _currentStep == 3 ? StepState.indexed : StepState.disabled,
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
          ...['UHF 5 Week', 'UHF 9 Week', 'GZCL Method'].map((program) =>
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
          if (details.stepIndex < 3)
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
      // Validate training maxes
      if (_squatController.text.isEmpty ||
          _benchController.text.isEmpty ||
          _deadliftController.text.isEmpty ||
          _ohpController.text.isEmpty) {
        throw Exception('Please enter all training maxes');
      }
      
      // Parse training maxes
      final squatTM = double.tryParse(_squatController.text);
      final benchTM = double.tryParse(_benchController.text);
      final deadliftTM = double.tryParse(_deadliftController.text);
      final ohpTM = double.tryParse(_ohpController.text);
      
      if (squatTM == null || benchTM == null || deadliftTM == null || ohpTM == null) {
        throw Exception('Please enter valid numbers for training maxes');
      }
      
      // Create training max objects
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
      
      // Show success message
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
        
        // Trigger callback and navigate back after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            widget.onProgramCreated?.call();
          }
        });
      }
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
    super.dispose();
  }
}