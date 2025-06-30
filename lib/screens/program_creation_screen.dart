import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../widgets/samurai_icons.dart';
import '../models/program.dart';
import '../models/user_profile.dart';
import '../programs/hip_aware_powerlifting_program.dart';
import '../services/program_management_service.dart';
import '../services/powerlifting_program_service.dart';
import '../repositories/hive_database.dart';

class ProgramCreationScreen extends StatefulWidget {
  final VoidCallback? onProgramCreated;
  
  const ProgramCreationScreen({super.key, this.onProgramCreated});

  @override
  State<ProgramCreationScreen> createState() => _ProgramCreationScreenState();
}

class _ProgramCreationScreenState extends State<ProgramCreationScreen> {
  final ProgramManagementService _programManagement = ProgramManagementService();
  final PowerliftingProgramService _powerliftingService = PowerliftingProgramService();
  final PageController _pageController = PageController();
  
  int _currentStep = 0;
  bool _isCreating = false;
  String _momentumWarningMessage = '';
  
  // Available Programs
  late final List<ProgramOption> _availablePrograms;
  ProgramOption? _selectedProgram;
  
  // User Profile Data
  final _nameController = TextEditingController();
  String _experienceLevel = 'Intermediate';
  bool _useKilograms = false;
  bool _hasHipIssues = true;
  String _hipSide = 'left';
  
  // Training Max Controllers
  final _squatController = TextEditingController();
  final _benchController = TextEditingController();
  final _deadliftController = TextEditingController();
  final _ohpController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initializePrograms();
    _loadExistingUserData();
    // Check for existing program but don't show warning immediately
    _checkExistingProgram();
  }

  void _initializePrograms() {
    _availablePrograms = [
      ProgramOption(
        id: 'hip_aware_powerlifting',
        name: 'Hip-Aware Powerlifting Program',
        description: 'An 18-week powerlifting program designed to address hip imbalances while building maximum strength in the squat, bench press, and deadlift.',
        difficulty: DifficultyLevel.intermediate,
        duration: 18,
        specializations: ['Hip Health', 'Powerlifting', 'Strength Building'],
        icon: SamuraiIcons.katana,
        factory: () => HipAwarePowerliftingProgramFactory.createProgram(),
      ),
      // Future programs can be added here
    ];
    _selectedProgram = _availablePrograms.first;
  }

  Future<void> _checkExistingProgram() async {
    try {
      final hasProgram = await _programManagement.hasActiveProgram();
      if (hasProgram) {
        final recommendation = await _programManagement.getProgramSwitchRecommendation();
        // Store the warning info for use in the confirmation dialog
        _momentumWarningMessage = recommendation.message;
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _loadExistingUserData() async {
    try {
      final userProfileBox = HiveDatabase.userProfileBox;
      final userProfile = userProfileBox.get('current_user');
      
      if (userProfile != null) {
        setState(() {
          _nameController.text = userProfile.name;
          _experienceLevel = userProfile.experienceLevel;
          _useKilograms = false; // Default to pounds for existing users
          _hasHipIssues = userProfile.hipIssues;
          _hipSide = userProfile.hipSide;
          
          // Load existing training maxes if available
          final maxes = userProfile.currentMaxes;
          _squatController.text = (maxes['squat'] ?? 0).toString();
          _benchController.text = (maxes['inclineBench'] ?? 0).toString();
          _deadliftController.text = (maxes['deadlift'] ?? 0).toString();
          _ohpController.text = (maxes['ohp'] ?? 0).toString();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamuraiColors.midnightBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'FORGE YOUR PATH',
          style: SamuraiTextStyles.katanaSharp(
            fontSize: 20,
            color: SamuraiColors.goldenKoi,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SamuraiColors.goldenKoi),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
              children: [
                _buildProgramSelectionStep(),
                _buildProfileSetupStep(),
                _buildTrainingMaxesStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }


  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? SamuraiColors.goldenKoi
                    : SamuraiColors.ironGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgramSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Path',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 24,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the training program that aligns with your goals and experience.',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 24),
          ..._availablePrograms.map((program) => _buildProgramCard(program)),
        ],
      ),
    );
  }

  Widget _buildProgramCard(ProgramOption program) {
    final isSelected = _selectedProgram?.id == program.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SamuraiColors.midnightBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? SamuraiColors.goldenKoi : SamuraiColors.ironGray,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedProgram = program),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      program.icon,
                      color: isSelected ? SamuraiColors.goldenKoi : SamuraiColors.ashWhite,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.name,
                            style: SamuraiTextStyles.katanaSharp(
                              fontSize: 18,
                              color: isSelected ? SamuraiColors.goldenKoi : SamuraiColors.ashWhite,
                            ),
                          ),
                          Text(
                            '${program.duration} weeks • ${program.difficulty.name.toUpperCase()}',
                            style: SamuraiTextStyles.ancientWisdom(
                              fontSize: 12,
                              color: SamuraiColors.sakuraPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: SamuraiColors.goldenKoi,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  program.description,
                  style: SamuraiTextStyles.brushStroke(
                    fontSize: 14,
                    color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: program.specializations.map((spec) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? SamuraiColors.goldenKoi.withValues(alpha: 0.2)
                          : SamuraiColors.ironGray.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      spec,
                      style: TextStyle(
                        color: isSelected ? SamuraiColors.goldenKoi : SamuraiColors.ashWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSetupStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Warrior Profile',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 24,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself to personalize your training experience.',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildTextField(
            controller: _nameController,
            label: 'Warrior Name',
            hint: 'Enter your name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          
          _buildDropdownField(
            label: 'Training Experience',
            value: _experienceLevel,
            options: ['Beginner', 'Intermediate', 'Advanced'],
            onChanged: (value) => setState(() => _experienceLevel = value!),
            icon: Icons.fitness_center,
          ),
          const SizedBox(height: 16),
          
          _buildSwitchField(
            label: 'Use Kilograms',
            value: _useKilograms,
            onChanged: (value) => setState(() => _useKilograms = value),
            icon: Icons.scale,
          ),
          const SizedBox(height: 24),
          
          if (_selectedProgram?.id == 'hip_aware_powerlifting') ...[
            Text(
              'Hip Assessment',
              style: SamuraiTextStyles.katanaSharp(
                fontSize: 18,
                color: SamuraiColors.goldenKoi,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSwitchField(
              label: 'I have hip mobility/strength imbalances',
              value: _hasHipIssues,
              onChanged: (value) => setState(() => _hasHipIssues = value),
              icon: Icons.accessibility,
            ),
            
            if (_hasHipIssues) ...[
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Weaker Hip Side',
                value: _hipSide,
                options: ['left', 'right'],
                onChanged: (value) => setState(() => _hipSide = value!),
                icon: Icons.accessibility_new,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTrainingMaxesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training Maxes',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 24,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your current training maxes or leave empty to perform max testing.',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildTextField(
            controller: _squatController,
            label: 'Squat ${_useKilograms ? '(kg)' : '(lbs)'}',
            hint: 'Optional - leave empty for max testing',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _benchController,
            label: 'Incline Bench Press ${_useKilograms ? '(kg)' : '(lbs)'}',
            hint: 'Optional - leave empty for max testing',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _deadliftController,
            label: 'Deadlift ${_useKilograms ? '(kg)' : '(lbs)'}',
            hint: 'Optional - leave empty for max testing',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _ohpController,
            label: 'Overhead Press ${_useKilograms ? '(kg)' : '(lbs)'}',
            hint: 'Optional',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: SamuraiColors.contemplativeBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Max Testing Protocol',
                      style: SamuraiTextStyles.katanaSharp(
                        fontSize: 14,
                        color: SamuraiColors.contemplativeBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'If you leave training maxes empty, your first workout will be a guided max testing protocol to safely establish your training loads.',
                  style: SamuraiTextStyles.brushStroke(
                    fontSize: 12,
                    color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Your Path',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 24,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your program setup before beginning your journey.',
            style: SamuraiTextStyles.brushStroke(
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildConfirmationCard('Program', _selectedProgram?.name ?? 'Not selected'),
          _buildConfirmationCard('Duration', '${_selectedProgram?.duration ?? 0} weeks'),
          _buildConfirmationCard('Difficulty', _selectedProgram?.difficulty.name.toUpperCase() ?? ''),
          _buildConfirmationCard('Warrior Name', _nameController.text.isEmpty ? 'Not provided' : _nameController.text),
          _buildConfirmationCard('Experience', _experienceLevel),
          _buildConfirmationCard('Units', _useKilograms ? 'Kilograms' : 'Pounds'),
          
          if (_hasHipIssues && _selectedProgram?.id == 'hip_aware_powerlifting') ...[
            _buildConfirmationCard('Hip Focus', 'Weaker ${_hipSide} side'),
          ],
          
          const SizedBox(height: 16),
          Text(
            'Training Maxes',
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 16,
              color: SamuraiColors.goldenKoi,
            ),
          ),
          const SizedBox(height: 8),
          
          if (_hasTrainingMaxes()) ...[
            _buildConfirmationCard('Squat', '${_squatController.text} ${_useKilograms ? 'kg' : 'lbs'}'),
            _buildConfirmationCard('Incline Bench', '${_benchController.text} ${_useKilograms ? 'kg' : 'lbs'}'),
            _buildConfirmationCard('Deadlift', '${_deadliftController.text} ${_useKilograms ? 'kg' : 'lbs'}'),
            if (_ohpController.text.isNotEmpty)
              _buildConfirmationCard('Overhead Press', '${_ohpController.text} ${_useKilograms ? 'kg' : 'lbs'}'),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SamuraiColors.sanguineRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: SamuraiColors.sanguineRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assessment, color: SamuraiColors.sanguineRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Max testing protocol will be your first workout',
                      style: SamuraiTextStyles.brushStroke(
                        fontSize: 12,
                        color: SamuraiColors.ashWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmationCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SamuraiTextStyles.brushStroke(
              fontSize: 14,
              color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 14,
              color: SamuraiColors.goldenKoi,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SamuraiTextStyles.brushStroke(
            fontSize: 14,
            color: SamuraiColors.ashWhite,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: SamuraiColors.ashWhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: SamuraiColors.ashWhite.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, color: SamuraiColors.goldenKoi),
            filled: true,
            fillColor: SamuraiColors.ironGray.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: SamuraiColors.ironGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: SamuraiColors.goldenKoi),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SamuraiTextStyles.brushStroke(
            fontSize: 14,
            color: SamuraiColors.ashWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: SamuraiColors.ironGray.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SamuraiColors.ironGray),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            style: const TextStyle(color: SamuraiColors.ashWhite),
            dropdownColor: SamuraiColors.midnightBlack,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: SamuraiColors.goldenKoi),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SamuraiColors.ironGray),
      ),
      child: Row(
        children: [
          Icon(icon, color: SamuraiColors.goldenKoi),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: SamuraiTextStyles.brushStroke(
                fontSize: 14,
                color: SamuraiColors.ashWhite,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: SamuraiColors.goldenKoi,
            activeTrackColor: SamuraiColors.goldenKoi.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                  _pageController.animateToPage(
                    _currentStep,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamuraiColors.ironGray,
                  foregroundColor: SamuraiColors.ashWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('BACK'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isCreating ? null : _handleNextOrCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: SamuraiColors.goldenKoi,
                foregroundColor: SamuraiColors.midnightBlack,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: SamuraiColors.midnightBlack,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_currentStep == 3 ? 'CREATE PROGRAM' : 'NEXT'),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasTrainingMaxes() {
    return _squatController.text.isNotEmpty &&
           _benchController.text.isNotEmpty &&
           _deadliftController.text.isNotEmpty;
  }

  void _handleNextOrCreate() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _createProgram();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedProgram != null;
      case 1:
        return _nameController.text.isNotEmpty;
      case 2:
        return true; // Training maxes are optional
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _createProgram() async {
    if (_selectedProgram == null) return;
    
    setState(() => _isCreating = true);
    
    try {
      // Check for existing program and show confirmation if needed
      final hasProgram = await _programManagement.hasActiveProgram();
      bool shouldProceed = true;
      
      if (hasProgram) {
        // Show confirmation dialog only once
        shouldProceed = await _showProgramSwitchConfirmation();
      }
      
      if (!shouldProceed) {
        setState(() => _isCreating = false);
        return;
      }
      
      // Create user profile
      final userProfile = UserProfile(
        name: _nameController.text,
        currentWeek: 1,
        currentBlock: 'Accumulation',
        currentMaxes: _getTrainingMaxes(),
        targetMaxes: _calculateTargetMaxes(_getTrainingMaxes()),
        hipIssues: _hasHipIssues,
        hipSide: _hasHipIssues ? _hipSide : 'left',
        programStartDate: DateTime.now(),
        completedWorkouts: [],
        trainingExperience: 12, // Default to 12 months
        experienceLevel: _experienceLevel,
        trainingFrequency: 5, // 5 days per week
      );
      
      // Save user profile
      final userProfileBox = HiveDatabase.userProfileBox;
      await userProfileBox.put('current_user', userProfile);
      
      // Create program using the factory
      final program = _selectedProgram!.factory();
      
      // Start the program using the management service
      final result = await _programManagement.startProgram(
        program: program,
        startingMaxes: _getTrainingMaxes(),
        userNotes: 'Program created via new setup flow',
        forceSwitch: true, // Force switch since user confirmed
      );
      
      if (result.success) {
        // Initialize the legacy powerlifting service for backward compatibility
        await _powerliftingService.initializeProgram(userProfile);
        
        // Call the callback if provided
        widget.onProgramCreated?.call();
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _hasTrainingMaxes() 
                    ? 'Program created successfully! Ready to train.'
                    : 'Program created! Your first workout will be max testing.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to create program: ${result.warningMessage}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating program: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Map<String, int> _getTrainingMaxes() {
    return {
      'squat': int.tryParse(_squatController.text) ?? 0,
      'inclineBench': int.tryParse(_benchController.text) ?? 0,
      'deadlift': int.tryParse(_deadliftController.text) ?? 0,
      'ohp': int.tryParse(_ohpController.text) ?? 0,
    };
  }

  Map<String, int> _calculateTargetMaxes(Map<String, int> currentMaxes) {
    // Calculate target maxes based on typical intermediate progression
    return {
      'squat': ((currentMaxes['squat'] ?? 0) * 1.3).round(),
      'inclineBench': ((currentMaxes['inclineBench'] ?? 0) * 1.25).round(),
      'deadlift': ((currentMaxes['deadlift'] ?? 0) * 1.4).round(),
      'ohp': ((currentMaxes['ohp'] ?? 0) * 1.2).round(),
    };
  }

  Future<bool> _showProgramSwitchConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SamuraiColors.midnightBlack,
        title: Text(
          'Switch Program?',
          style: SamuraiTextStyles.katanaSharp(
            fontSize: 18,
            color: SamuraiColors.goldenKoi,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _momentumWarningMessage.isNotEmpty 
                  ? _momentumWarningMessage
                  : 'You have an active program. Creating a new program will archive your current progress.',
              style: SamuraiTextStyles.brushStroke(
                color: SamuraiColors.ashWhite,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will archive your current program and start fresh.',
                      style: SamuraiTextStyles.ancientWisdom(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: SamuraiTextStyles.brushStroke(
                color: SamuraiColors.ashWhite,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: SamuraiColors.ashWhite,
            ),
            child: const Text('Create New Program'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _squatController.dispose();
    _benchController.dispose();
    _deadliftController.dispose();
    _ohpController.dispose();
    super.dispose();
  }
}

class ProgramOption {
  final String id;
  final String name;
  final String description;
  final DifficultyLevel difficulty;
  final int duration;
  final List<String> specializations;
  final IconData icon;
  final Program Function() factory;

  ProgramOption({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.specializations,
    required this.icon,
    required this.factory,
  });
}