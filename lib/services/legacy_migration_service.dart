import '../models/program_history.dart';
import '../models/user_profile.dart';
import '../programs/hip_aware_powerlifting_program.dart';
import '../repositories/hive_database.dart';
import 'program_management_service.dart';
import 'powerlifting_program_service.dart';

/// Service to handle migration from legacy powerlifting program to new OO architecture
class LegacyMigrationService {
  final ProgramManagementService _programManagement = ProgramManagementService();
  final PowerliftingProgramService _powerliftingService = PowerliftingProgramService();

  /// Check if there's legacy data that needs migration
  Future<bool> hasLegacyData() async {
    try {
      // Check for legacy powerlifting program
      final hasLegacyProgram = await _powerliftingService.isProgramActive();
      
      // Check if we already have a new architecture program
      final hasNewProgram = await _programManagement.hasActiveProgram();
      
      // We have legacy data if there's an old program but no new program
      return hasLegacyProgram && !hasNewProgram;
    } catch (e) {
      return false;
    }
  }

  /// Get legacy program information for user review
  Future<LegacyProgramInfo?> getLegacyProgramInfo() async {
    try {
      if (!await hasLegacyData()) return null;

      final userProfileBox = HiveDatabase.userProfileBox;
      final userProfile = userProfileBox.get('current_user');
      
      if (userProfile == null) return null;

      final currentWeek = await _powerliftingService.getCurrentWeek();
      final prefs = HiveDatabase.userPreferencesBox;
      final startDateString = prefs.get('program_start_date') as String?;
      
      DateTime? startDate;
      if (startDateString != null) {
        startDate = DateTime.tryParse(startDateString);
      }

      return LegacyProgramInfo(
        programName: 'Hip-Aware Powerlifting Program (Legacy)',
        currentWeek: currentWeek,
        totalWeeks: 18,
        startDate: startDate ?? DateTime.now().subtract(Duration(days: (currentWeek - 1) * 7)),
        userProfile: userProfile,
        currentMaxes: userProfile.currentMaxes,
      );
    } catch (e) {
      return null;
    }
  }

  /// Migrate legacy program to new architecture
  Future<MigrationResult> migrateLegacyProgram() async {
    try {
      final legacyInfo = await getLegacyProgramInfo();
      if (legacyInfo == null) {
        return MigrationResult(
          success: false,
          message: 'No legacy program found to migrate',
        );
      }

      // Create the new program using the factory
      final program = HipAwarePowerliftingProgramFactory.createProgram();

      // Create an active program from legacy data
      final activeProgram = ActiveProgram(
        id: 'migrated_${DateTime.now().millisecondsSinceEpoch}',
        programName: program.name,
        startDate: legacyInfo.startDate,
        startingMaxes: legacyInfo.currentMaxes,
        programVersion: program.metadata.version,
        currentWeek: legacyInfo.currentWeek,
        currentPhase: _getCurrentPhaseForWeek(legacyInfo.currentWeek),
        currentMaxes: legacyInfo.currentMaxes,
        userNotes: 'Migrated from legacy powerlifting program',
      );

      // Get or create program history
      final history = await _programManagement.getProgramHistory();
      
      // Add the migrated program as current
      history.currentProgram = activeProgram;
      history.lastUpdated = DateTime.now();
      await history.save();

      // Clear legacy flags but keep the data for reference
      final prefs = HiveDatabase.userPreferencesBox;
      await prefs.put('powerlifting_program_active', false);
      await prefs.put('legacy_migrated', true);
      await prefs.put('legacy_migration_date', DateTime.now().toIso8601String());

      return MigrationResult(
        success: true,
        message: 'Legacy program successfully migrated to new architecture',
        migratedProgram: activeProgram,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        message: 'Migration failed: $e',
      );
    }
  }

  /// Delete all legacy data (for testing or fresh start)
  Future<void> deleteLegacyData() async {
    try {
      final prefs = HiveDatabase.userPreferencesBox;
      final workoutBox = HiveDatabase.workoutBox;
      
      // Clear legacy program flags
      await prefs.delete('powerlifting_program_active');
      await prefs.delete('current_week');
      await prefs.delete('program_start_date');
      
      // Clear legacy workouts
      await workoutBox.clear();
      
      // Mark as cleaned
      await prefs.put('legacy_data_cleared', true);
      await prefs.put('legacy_clear_date', DateTime.now().toIso8601String());
      
    } catch (e) {
      throw Exception('Failed to delete legacy data: $e');
    }
  }

  /// Reset everything for testing (nuclear option)
  Future<void> resetAllData() async {
    try {
      // Clear all Hive data
      await HiveDatabase.clearAllData();
      
      // Could also reset any other persistent storage here
      
    } catch (e) {
      throw Exception('Failed to reset all data: $e');
    }
  }

  /// Check if migration has been completed
  Future<bool> hasMigrationCompleted() async {
    try {
      final prefs = HiveDatabase.userPreferencesBox;
      return prefs.get('legacy_migrated', defaultValue: false) as bool;
    } catch (e) {
      return false;
    }
  }

  String _getCurrentPhaseForWeek(int week) {
    if (week <= 6) return 'Accumulation';
    if (week <= 12) return 'Intensification';
    return 'Peaking';
  }
}

class LegacyProgramInfo {
  final String programName;
  final int currentWeek;
  final int totalWeeks;
  final DateTime startDate;
  final UserProfile userProfile;
  final Map<String, int> currentMaxes;

  LegacyProgramInfo({
    required this.programName,
    required this.currentWeek,
    required this.totalWeeks,
    required this.startDate,
    required this.userProfile,
    required this.currentMaxes,
  });

  double get progressPercentage => currentWeek / totalWeeks;
  int get daysInProgram => DateTime.now().difference(startDate).inDays;
}

class MigrationResult {
  final bool success;
  final String message;
  final ActiveProgram? migratedProgram;

  MigrationResult({
    required this.success,
    required this.message,
    this.migratedProgram,
  });
}