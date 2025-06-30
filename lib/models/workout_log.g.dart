// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogAdapter extends TypeAdapter<WorkoutLog> {
  @override
  final int typeId = 15;

  @override
  WorkoutLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLog(
      id: fields[0] as String,
      workoutId: fields[1] as String,
      completedDate: fields[2] as DateTime,
      exerciseData: (fields[3] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<WorkoutSet>())),
      notes: fields[4] as String,
      overallRPE: fields[5] as int,
      hipDiscomfort: fields[6] as bool,
      hipNotes: fields[7] as String?,
      duration: fields[8] as int,
      hipComfortRating: fields[9] as int,
      completedHipActivation: fields[10] as bool,
      additionalMetrics: (fields[11] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLog obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutId)
      ..writeByte(2)
      ..write(obj.completedDate)
      ..writeByte(3)
      ..write(obj.exerciseData)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.overallRPE)
      ..writeByte(6)
      ..write(obj.hipDiscomfort)
      ..writeByte(7)
      ..write(obj.hipNotes)
      ..writeByte(8)
      ..write(obj.duration)
      ..writeByte(9)
      ..write(obj.hipComfortRating)
      ..writeByte(10)
      ..write(obj.completedHipActivation)
      ..writeByte(11)
      ..write(obj.additionalMetrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutSetAdapter extends TypeAdapter<WorkoutSet> {
  @override
  final int typeId = 16;

  @override
  WorkoutSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSet(
      weight: fields[0] as double,
      reps: fields[1] as int,
      rpe: fields[2] as int?,
      completed: fields[3] as bool,
      notes: fields[4] as String?,
      isPersonalRecord: fields[5] as bool?,
      completedAt: fields[6] as DateTime?,
      restTime: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSet obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.rpe)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.isPersonalRecord)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.restTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
