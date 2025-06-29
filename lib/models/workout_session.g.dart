// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 2;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      weekNumber: fields[2] as int,
      dayNumber: fields[3] as int,
      sets: (fields[4] as List).cast<ExerciseSet>(),
      totalDuration: fields[5] as Duration,
      subjectiveMarkers: fields[6] as SubjectiveMarkers,
      isCompleted: fields[7] as bool,
      notes: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weekNumber)
      ..writeByte(3)
      ..write(obj.dayNumber)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.totalDuration)
      ..writeByte(6)
      ..write(obj.subjectiveMarkers)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseSetAdapter extends TypeAdapter<ExerciseSet> {
  @override
  final int typeId = 3;

  @override
  ExerciseSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSet(
      id: fields[0] as String,
      exercise: fields[1] as String,
      tier: fields[2] as TierType,
      weight: fields[3] as double,
      targetReps: fields[4] as int,
      actualReps: fields[5] as int,
      rpe: fields[6] as double,
      isAMRAP: fields[7] as bool,
      restTime: fields[8] as Duration,
      notes: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exercise)
      ..writeByte(2)
      ..write(obj.tier)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.targetReps)
      ..writeByte(5)
      ..write(obj.actualReps)
      ..writeByte(6)
      ..write(obj.rpe)
      ..writeByte(7)
      ..write(obj.isAMRAP)
      ..writeByte(8)
      ..write(obj.restTime)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectiveMarkersAdapter extends TypeAdapter<SubjectiveMarkers> {
  @override
  final int typeId = 5;

  @override
  SubjectiveMarkers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectiveMarkers(
      energy: fields[0] as double,
      motivation: fields[1] as double,
      soreness: fields[2] as double,
      sleepQuality: fields[3] as double,
      stressLevel: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SubjectiveMarkers obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.energy)
      ..writeByte(1)
      ..write(obj.motivation)
      ..writeByte(2)
      ..write(obj.soreness)
      ..writeByte(3)
      ..write(obj.sleepQuality)
      ..writeByte(4)
      ..write(obj.stressLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectiveMarkersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TierTypeAdapter extends TypeAdapter<TierType> {
  @override
  final int typeId = 4;

  @override
  TierType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TierType.t1;
      case 1:
        return TierType.t2;
      case 2:
        return TierType.t3;
      default:
        return TierType.t1;
    }
  }

  @override
  void write(BinaryWriter writer, TierType obj) {
    switch (obj) {
      case TierType.t1:
        writer.writeByte(0);
        break;
      case TierType.t2:
        writer.writeByte(1);
        break;
      case TierType.t3:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TierTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
