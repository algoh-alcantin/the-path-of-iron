import 'package:flutter/material.dart';
import '../models/program_history.dart';
import '../services/program_management_service.dart';

class ProgramHistoryScreen extends StatefulWidget {
  const ProgramHistoryScreen({super.key});

  @override
  State<ProgramHistoryScreen> createState() => _ProgramHistoryScreenState();
}

class _ProgramHistoryScreenState extends State<ProgramHistoryScreen> {
  final ProgramManagementService _programService = ProgramManagementService();
  ProgramHistory? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgramHistory();
  }

  Future<void> _loadProgramHistory() async {
    try {
      final history = await _programService.getProgramHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading program history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PROGRAM HISTORY',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB8860B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8860B)),
              ),
            )
          : _history == null
              ? _buildErrorState()
              : _buildHistoryContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFB8860B),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load program history',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProgramHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8860B),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentProgramSection(),
          const SizedBox(height: 24),
          _buildStatisticsSection(),
          const SizedBox(height: 24),
          _buildCompletedProgramsSection(),
          const SizedBox(height: 24),
          _buildProgramSwitchingSection(),
        ],
      ),
    );
  }

  Widget _buildCurrentProgramSection() {
    final currentProgram = _history!.currentProgram;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB8860B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT PROGRAM',
            style: TextStyle(
              color: Color(0xFFB8860B),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          if (currentProgram != null) ...[
            Text(
              currentProgram.programName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Week ${currentProgram.currentWeek} • ${currentProgram.currentPhase}',
              style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '${currentProgram.getDaysInProgram()} days in program',
              style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: currentProgram.getProgressPercentage(18),
              backgroundColor: const Color(0xFF333333),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB8860B)),
            ),
            const SizedBox(height: 8),
            Text(
              '${(currentProgram.getProgressPercentage(18) * 100).round()}% Complete',
              style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
            ),
          ] else ...[
            const Text(
              'No active program',
              style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showProgramSelectionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8860B),
              ),
              child: const Text('Start New Program'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return FutureBuilder<ProgramStatistics>(
      future: _programService.getStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TRAINING STATISTICS',
                style: TextStyle(
                  color: Color(0xFFB8860B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Programs Completed',
                      stats.totalProgramsCompleted.toString(),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Current Streak',
                      stats.currentStreak.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Training Time',
                      '${stats.totalTrainingTime.inDays} days',
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Completion Rate',
                      '${stats.averageCompletionRate.round()}%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompletedProgramsSection() {
    final completedPrograms = _history!.completedPrograms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPLETED PROGRAMS',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        if (completedPrograms.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No completed programs yet. Start your first program to see your progress here!',
              style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
            ),
          ),
        ] else ...[
          ...completedPrograms.map((program) => _buildCompletedProgramCard(program)),
        ],
      ],
    );
  }

  Widget _buildCompletedProgramCard(CompletedProgram program) {
    final gains = program.getStrengthGains();
    final totalGainPercentage = program.getTotalGainPercentage();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  program.programName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(program.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Duration: ${program.actualDuration.inDays} days',
            style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
          ),
          if (program.rating != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                ...List.generate(5, (index) => Icon(
                  index < program.rating! ? Icons.star : Icons.star_border,
                  color: const Color(0xFFB8860B),
                  size: 16,
                )),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Strength Gains: +${totalGainPercentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Color(0xFFB8860B),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...gains.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                ),
                Text(
                  '+${entry.value}kg',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CompletionStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case CompletionStatus.completed:
        color = Colors.green;
        text = 'COMPLETED';
        break;
      case CompletionStatus.incomplete:
        color = Colors.orange;
        text = 'INCOMPLETE';
        break;
      case CompletionStatus.abandoned:
        color = Colors.red;
        text = 'ABANDONED';
        break;
      case CompletionStatus.injury:
        color = Colors.purple;
        text = 'INJURY';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgramSwitchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PROGRAM MANAGEMENT',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        if (_history!.currentProgram != null) ...[
          ElevatedButton.icon(
            onPressed: _showProgramSwitchDialog,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Switch Program'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showCompleteProgramDialog,
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete Program'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: _showProgramSelectionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Start New Program'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8860B),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showProgramSwitchDialog() async {
    final recommendation = await _programService.getProgramSwitchRecommendation();
    
    if (!mounted) return;

    final shouldSwitch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Switch Program?',
          style: TextStyle(color: Color(0xFFB8860B)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation.message,
              style: const TextStyle(color: Colors.white),
            ),
            if (recommendation.momentumLoss != null) ...[
              const SizedBox(height: 12),
              Text(
                'Momentum Loss: ${recommendation.momentumLoss}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to switch programs? This will archive your current progress.',
              style: TextStyle(color: Color(0xFFCCCCCC)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFCCCCCC))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (shouldSwitch == true) {
      _showProgramSelectionDialog();
    }
  }

  Future<void> _showCompleteProgramDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CompleteProgramDialog(),
    );

    if (result != null) {
      try {
        // Get current user maxes as final maxes
        final currentProgram = _history!.currentProgram;
        final finalMaxes = currentProgram?.currentMaxes ?? <String, int>{};
        
        await _programService.completeCurrentProgram(
          status: result['status'],
          finalMaxes: finalMaxes,
          userReview: result['review'],
          rating: result['rating'],
        );
        
        await _loadProgramHistory();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program completed successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error completing program: $e')),
          );
        }
      }
    }
  }

  Future<void> _showProgramSelectionDialog() async {
    // For now, just show the Hip-Aware Powerlifting Program
    // In the future, this could show multiple program options
    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Start New Program',
          style: TextStyle(color: Color(0xFFB8860B)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hip-Aware Powerlifting Program',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '18-week powerlifting program designed to address hip imbalances while building maximum strength.',
              style: TextStyle(color: Color(0xFFCCCCCC)),
            ),
            SizedBox(height: 12),
            Text(
              'Difficulty: Intermediate',
              style: TextStyle(color: Color(0xFFB8860B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFCCCCCC))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8860B),
            ),
            child: const Text('Start Program'),
          ),
        ],
      ),
    );

    if (shouldStart == true) {
      // Navigate to program setup
      if (mounted) {
        Navigator.pop(context); // Close history screen
        Navigator.pushNamed(context, '/program-setup');
      }
    }
  }
}

class _CompleteProgramDialog extends StatefulWidget {
  @override
  State<_CompleteProgramDialog> createState() => _CompleteProgramDialogState();
}

class _CompleteProgramDialogState extends State<_CompleteProgramDialog> {
  CompletionStatus _status = CompletionStatus.completed;
  String _review = '';
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text(
        'Complete Program',
        style: TextStyle(color: Color(0xFFB8860B)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How did your program go?',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Status:',
            style: TextStyle(color: Color(0xFFCCCCCC)),
          ),
          DropdownButton<CompletionStatus>(
            value: _status,
            dropdownColor: const Color(0xFF2A2A2A),
            items: CompletionStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _status = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Rating:',
            style: TextStyle(color: Color(0xFFCCCCCC)),
          ),
          Row(
            children: List.generate(5, (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFB8860B),
                size: 24,
              ),
            )),
          ),
          const SizedBox(height: 16),
          const Text(
            'Review (optional):',
            style: TextStyle(color: Color(0xFFCCCCCC)),
          ),
          TextField(
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            onChanged: (value) {
              _review = value;
            },
            decoration: const InputDecoration(
              hintText: 'How was the program? What did you learn?',
              hintStyle: TextStyle(color: Color(0xFF666666)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF666666)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB8860B)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFFCCCCCC))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'status': _status,
              'rating': _rating,
              'review': _review.isNotEmpty ? _review : null,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Complete'),
        ),
      ],
    );
  }
}