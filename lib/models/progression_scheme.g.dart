// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression_scheme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressionSchemeAdapter extends TypeAdapter<ProgressionScheme> {
  @override
  final int typeId = 6;

  @override
  ProgressionScheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressionScheme(
      id: fields[0] as String,
      tier: fields[1] as TierType,
      weeklyProgressions: (fields[2] as Map).cast<int, WeeklyProgression>(),
      autoregulationRules: fields[3] as AutoregulationRules,
      isActive: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressionScheme obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tier)
      ..writeByte(2)
      ..write(obj.weeklyProgressions)
      ..writeByte(3)
      ..write(obj.autoregulationRules)
      ..writeByte(4)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionSchemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeeklyProgressionAdapter extends TypeAdapter<WeeklyProgression> {
  @override
  final int typeId = 7;

  @override
  WeeklyProgression read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyProgression(
      week: fields[0] as int,
      dailyProgressions: (fields[1] as Map).cast<int, DailyProgression>(),
      isDeloadWeek: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyProgression obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.week)
      ..writeByte(1)
      ..write(obj.dailyProgressions)
      ..writeByte(2)
      ..write(obj.isDeloadWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyProgressionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyProgressionAdapter extends TypeAdapter<DailyProgression> {
  @override
  final int typeId = 8;

  @override
  DailyProgression read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyProgression(
      day: fields[0] as int,
      setProgressions: (fields[1] as List).cast<SetProgression>(),
      intensityModifier: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DailyProgression obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.setProgressions)
      ..writeByte(2)
      ..write(obj.intensityModifier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyProgressionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetProgressionAdapter extends TypeAdapter<SetProgression> {
  @override
  final int typeId = 9;

  @override
  SetProgression read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetProgression(
      percentage: fields[0] as double,
      repScheme: fields[1] as RepScheme,
      isAMRAP: fields[2] as bool,
      restTime: fields[3] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, SetProgression obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.percentage)
      ..writeByte(1)
      ..write(obj.repScheme)
      ..writeByte(2)
      ..write(obj.isAMRAP)
      ..writeByte(3)
      ..write(obj.restTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetProgressionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepSchemeAdapter extends TypeAdapter<RepScheme> {
  @override
  final int typeId = 10;

  @override
  RepScheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepScheme(
      minReps: fields[0] as int,
      maxReps: fields[1] as int,
      targetReps: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RepScheme obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.minReps)
      ..writeByte(1)
      ..write(obj.maxReps)
      ..writeByte(2)
      ..write(obj.targetReps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepSchemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AutoregulationRulesAdapter extends TypeAdapter<AutoregulationRules> {
  @override
  final int typeId = 11;

  @override
  AutoregulationRules read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AutoregulationRules(
      minTrainingMaxIncrease: fields[0] as double,
      maxTrainingMaxIncrease: fields[1] as double,
      minAMRAPRepsForIncrease: fields[2] as int,
      maxRPEForIncrease: fields[3] as double,
      consecutiveFailuresForDecrease: fields[4] as int,
      trainingMaxDecreaseAmount: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AutoregulationRules obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.minTrainingMaxIncrease)
      ..writeByte(1)
      ..write(obj.maxTrainingMaxIncrease)
      ..writeByte(2)
      ..write(obj.minAMRAPRepsForIncrease)
      ..writeByte(3)
      ..write(obj.maxRPEForIncrease)
      ..writeByte(4)
      ..write(obj.consecutiveFailuresForDecrease)
      ..writeByte(5)
      ..write(obj.trainingMaxDecreaseAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoregulationRulesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
