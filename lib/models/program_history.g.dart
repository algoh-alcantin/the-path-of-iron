// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgramHistoryAdapter extends TypeAdapter<ProgramHistory> {
  @override
  final int typeId = 34;

  @override
  ProgramHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramHistory(
      userId: fields[0] as String,
      completedPrograms: (fields[1] as List).cast<CompletedProgram>(),
      currentProgram: fields[2] as ActiveProgram?,
      savedTemplates: (fields[3] as List).cast<ProgramTemplate>(),
      lastUpdated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgramHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.completedPrograms)
      ..writeByte(2)
      ..write(obj.currentProgram)
      ..writeByte(3)
      ..write(obj.savedTemplates)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgramRecordAdapter extends TypeAdapter<ProgramRecord> {
  @override
  final int typeId = 35;

  @override
  ProgramRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramRecord(
      id: fields[0] as String,
      programName: fields[1] as String,
      startDate: fields[2] as DateTime,
      startingMaxes: (fields[3] as Map).cast<String, int>(),
      programVersion: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProgramRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programName)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.startingMaxes)
      ..writeByte(4)
      ..write(obj.programVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActiveProgramAdapter extends TypeAdapter<ActiveProgram> {
  @override
  final int typeId = 36;

  @override
  ActiveProgram read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActiveProgram(
      id: fields[0] as String,
      programName: fields[1] as String,
      startDate: fields[2] as DateTime,
      startingMaxes: (fields[3] as Map).cast<String, int>(),
      programVersion: fields[4] as String,
      currentWeek: fields[10] as int,
      currentPhase: fields[11] as String,
      currentMaxes: (fields[12] as Map).cast<String, int>(),
      completedWorkouts: (fields[13] as List).cast<String>(),
      progressData: (fields[14] as Map).cast<String, dynamic>(),
      userNotes: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActiveProgram obj) {
    writer
      ..writeByte(11)
      ..writeByte(10)
      ..write(obj.currentWeek)
      ..writeByte(11)
      ..write(obj.currentPhase)
      ..writeByte(12)
      ..write(obj.currentMaxes)
      ..writeByte(13)
      ..write(obj.completedWorkouts)
      ..writeByte(14)
      ..write(obj.progressData)
      ..writeByte(15)
      ..write(obj.userNotes)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programName)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.startingMaxes)
      ..writeByte(4)
      ..write(obj.programVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletedProgramAdapter extends TypeAdapter<CompletedProgram> {
  @override
  final int typeId = 37;

  @override
  CompletedProgram read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedProgram(
      id: fields[0] as String,
      programName: fields[1] as String,
      startDate: fields[2] as DateTime,
      startingMaxes: (fields[3] as Map).cast<String, int>(),
      programVersion: fields[4] as String,
      endDate: fields[20] as DateTime,
      finalMaxes: (fields[21] as Map).cast<String, int>(),
      status: fields[22] as CompletionStatus,
      results: fields[23] as ProgramResults,
      userReview: fields[24] as String?,
      rating: fields[25] as int?,
      actualDuration: fields[26] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, CompletedProgram obj) {
    writer
      ..writeByte(12)
      ..writeByte(20)
      ..write(obj.endDate)
      ..writeByte(21)
      ..write(obj.finalMaxes)
      ..writeByte(22)
      ..write(obj.status)
      ..writeByte(23)
      ..write(obj.results)
      ..writeByte(24)
      ..write(obj.userReview)
      ..writeByte(25)
      ..write(obj.rating)
      ..writeByte(26)
      ..write(obj.actualDuration)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programName)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.startingMaxes)
      ..writeByte(4)
      ..write(obj.programVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgramResultsAdapter extends TypeAdapter<ProgramResults> {
  @override
  final int typeId = 39;

  @override
  ProgramResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramResults(
      strengthGains: (fields[0] as Map).cast<String, int>(),
      totalWorkoutsCompleted: fields[1] as int,
      totalWorkoutsPlanned: fields[2] as int,
      adherencePercentage: fields[3] as double,
      averageRPE: (fields[4] as Map).cast<String, double>(),
      personalRecords: (fields[5] as List).cast<String>(),
      customMetrics: (fields[6] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgramResults obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.strengthGains)
      ..writeByte(1)
      ..write(obj.totalWorkoutsCompleted)
      ..writeByte(2)
      ..write(obj.totalWorkoutsPlanned)
      ..writeByte(3)
      ..write(obj.adherencePercentage)
      ..writeByte(4)
      ..write(obj.averageRPE)
      ..writeByte(5)
      ..write(obj.personalRecords)
      ..writeByte(6)
      ..write(obj.customMetrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StrengthProgressionAdapter extends TypeAdapter<StrengthProgression> {
  @override
  final int typeId = 40;

  @override
  StrengthProgression read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StrengthProgression(
      lift: fields[0] as String,
      dataPoints: (fields[1] as List).cast<StrengthDataPoint>(),
    );
  }

  @override
  void write(BinaryWriter writer, StrengthProgression obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lift)
      ..writeByte(1)
      ..write(obj.dataPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrengthProgressionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StrengthDataPointAdapter extends TypeAdapter<StrengthDataPoint> {
  @override
  final int typeId = 41;

  @override
  StrengthDataPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StrengthDataPoint(
      date: fields[0] as DateTime,
      weight: fields[1] as int,
      programName: fields[2] as String,
      isStarting: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StrengthDataPoint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.programName)
      ..writeByte(3)
      ..write(obj.isStarting);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrengthDataPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgramTemplateAdapter extends TypeAdapter<ProgramTemplate> {
  @override
  final int typeId = 42;

  @override
  ProgramTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      program: fields[2] as Program,
      userCustomizations: (fields[3] as Map).cast<String, dynamic>(),
      createdDate: fields[4] as DateTime,
      usageCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProgramTemplate obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.program)
      ..writeByte(3)
      ..write(obj.userCustomizations)
      ..writeByte(4)
      ..write(obj.createdDate)
      ..writeByte(5)
      ..write(obj.usageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletionStatusAdapter extends TypeAdapter<CompletionStatus> {
  @override
  final int typeId = 38;

  @override
  CompletionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CompletionStatus.completed;
      case 1:
        return CompletionStatus.incomplete;
      case 2:
        return CompletionStatus.abandoned;
      case 3:
        return CompletionStatus.injury;
      default:
        return CompletionStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, CompletionStatus obj) {
    switch (obj) {
      case CompletionStatus.completed:
        writer.writeByte(0);
        break;
      case CompletionStatus.incomplete:
        writer.writeByte(1);
        break;
      case CompletionStatus.abandoned:
        writer.writeByte(2);
        break;
      case CompletionStatus.injury:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
