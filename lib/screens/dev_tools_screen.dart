import 'package:flutter/material.dart';
import '../theme/samurai_theme.dart';
import '../services/legacy_migration_service.dart';
import '../services/program_management_service.dart';
import '../services/powerlifting_program_service.dart';
import '../repositories/hive_database.dart';

class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  final LegacyMigrationService _migrationService = LegacyMigrationService();
  final ProgramManagementService _programManagement = ProgramManagementService();
  final PowerliftingProgramService _powerliftingService = PowerliftingProgramService();
  
  bool _isLoading = false;
  String _statusMessage = '';
  LegacyProgramInfo? _legacyInfo;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final hasLegacy = await _migrationService.hasLegacyData();
      final hasNew = await _programManagement.hasActiveProgram();
      final legacyInfo = await _migrationService.getLegacyProgramInfo();
      final migrationCompleted = await _migrationService.hasMigrationCompleted();
      
      String status = '';
      if (hasLegacy && !hasNew) {
        status = 'Legacy program detected - migration available';
      } else if (hasNew && !hasLegacy) {
        status = 'New architecture program active';
      } else if (hasLegacy && hasNew) {
        status = 'Both legacy and new programs detected';
      } else if (migrationCompleted) {
        status = 'Migration completed - clean state';
      } else {
        status = 'No programs detected';
      }
      
      setState(() {
        _statusMessage = status;
        _legacyInfo = legacyInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading status: $e';
        _isLoading = false;
      });
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
          'DEV TOOLS',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(SamuraiColors.goldenKoi),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  if (_legacyInfo != null) _buildLegacyInfoCard(),
                  const SizedBox(height: 20),
                  _buildMigrationSection(),
                  const SizedBox(height: 20),
                  _buildDataManagementSection(),
                  const SizedBox(height: 20),
                  _buildDangerZone(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.ironGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SamuraiColors.goldenKoi, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: SamuraiColors.goldenKoi),
              const SizedBox(width: 8),
              Text(
                'SYSTEM STATUS',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 16,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _statusMessage,
            style: SamuraiTextStyles.brushStroke(
              fontSize: 14,
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: SamuraiColors.contemplativeBlue,
              foregroundColor: SamuraiColors.ashWhite,
            ),
            child: const Text('Refresh Status'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'LEGACY PROGRAM DETECTED',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Program', _legacyInfo!.programName),
          _buildInfoRow('Current Week', '${_legacyInfo!.currentWeek}/${_legacyInfo!.totalWeeks}'),
          _buildInfoRow('Progress', '${(_legacyInfo!.progressPercentage * 100).round()}%'),
          _buildInfoRow('Days Active', '${_legacyInfo!.daysInProgram} days'),
          _buildInfoRow('User', _legacyInfo!.userProfile.name),
          const SizedBox(height: 12),
          Text(
            'Training Maxes:',
            style: SamuraiTextStyles.brushStroke(
              fontSize: 14,
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 4),
          ..._legacyInfo!.currentMaxes.entries.map((entry) => 
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Text(
                '${entry.key}: ${entry.value}kg',
                style: SamuraiTextStyles.ancientWisdom(
                  fontSize: 12,
                  color: SamuraiColors.sakuraPink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SamuraiTextStyles.brushStroke(
              fontSize: 12,
              color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: SamuraiTextStyles.katanaSharp(
              fontSize: 12,
              color: SamuraiColors.goldenKoi,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMigrationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.contemplativeBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SamuraiColors.contemplativeBlue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upgrade, color: SamuraiColors.contemplativeBlue),
              const SizedBox(width: 8),
              Text(
                'MIGRATION TOOLS',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 16,
                  color: SamuraiColors.contemplativeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Migrate your legacy powerlifting program to the new object-oriented architecture.',
            style: SamuraiTextStyles.brushStroke(
              fontSize: 14,
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _legacyInfo != null ? _migrateLegacyProgram : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SamuraiColors.contemplativeBlue,
                    foregroundColor: SamuraiColors.ashWhite,
                  ),
                  child: const Text('Migrate Legacy Program'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.ashWhite.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SamuraiColors.ashWhite.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: SamuraiColors.ashWhite.withValues(alpha: 0.8)),
              const SizedBox(width: 8),
              Text(
                'DATA MANAGEMENT',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 16,
                  color: SamuraiColors.ashWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Manage stored program data and user profiles.',
            style: SamuraiTextStyles.brushStroke(
              fontSize: 14,
              color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _deleteLegacyData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: SamuraiColors.ashWhite,
                  ),
                  child: const Text('Clear Legacy Data'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _exportData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SamuraiColors.ironGray,
                    foregroundColor: SamuraiColors.ashWhite,
                  ),
                  child: const Text('Export Data'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SamuraiColors.sanguineRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SamuraiColors.sanguineRed, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dangerous, color: SamuraiColors.sanguineRed),
              const SizedBox(width: 8),
              Text(
                'DANGER ZONE',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 16,
                  color: SamuraiColors.sanguineRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'These actions will permanently delete data. Use with caution!',
            style: SamuraiTextStyles.brushStroke(
              fontSize: 14,
              color: SamuraiColors.ashWhite,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _resetAllData,
            style: ElevatedButton.styleFrom(
              backgroundColor: SamuraiColors.sanguineRed,
              foregroundColor: SamuraiColors.ashWhite,
            ),
            child: const Text('NUCLEAR RESET - Delete Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _migrateLegacyProgram() async {
    final confirmed = await _showConfirmationDialog(
      'Migrate Legacy Program',
      'This will migrate your legacy program to the new architecture. Your progress will be preserved. Continue?',
    );
    
    if (!confirmed) return;
    
    try {
      final result = await _migrationService.migrateLegacyProgram();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
        
        if (result.success) {
          await _loadStatus();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLegacyData() async {
    final confirmed = await _showConfirmationDialog(
      'Delete Legacy Data',
      'This will permanently delete all legacy program data. This cannot be undone. Continue?',
    );
    
    if (!confirmed) return;
    
    try {
      await _migrationService.deleteLegacyData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Legacy data deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete legacy data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await _showConfirmationDialog(
      'NUCLEAR RESET',
      'This will delete ALL data including programs, user profiles, and history. This is irreversible and primarily for testing. Are you absolutely sure?',
      dangerousAction: true,
    );
    
    if (!confirmed) return;
    
    try {
      await _migrationService.resetAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      // This is a placeholder for data export functionality
      // In a real implementation, you might export to JSON or CSV
      final prefs = HiveDatabase.userPreferencesBox;
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'preferences': prefs.toMap(),
        'status': _statusMessage,
      };
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data export: ${data.toString()}'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message, {bool dangerousAction = false}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SamuraiColors.midnightBlack,
        title: Text(
          title,
          style: TextStyle(
            color: dangerousAction ? SamuraiColors.sanguineRed : SamuraiColors.goldenKoi,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: SamuraiColors.ashWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: SamuraiColors.ashWhite)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerousAction ? SamuraiColors.sanguineRed : SamuraiColors.goldenKoi,
              foregroundColor: SamuraiColors.midnightBlack,
            ),
            child: Text(dangerousAction ? 'DELETE' : 'Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }
}