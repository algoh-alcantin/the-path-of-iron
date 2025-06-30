// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 14;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      id: fields[0] as String,
      dayName: fields[1] as String,
      workoutName: fields[2] as String,
      weekNumber: fields[3] as int,
      blockPhase: fields[4] as String,
      exercises: (fields[5] as List).cast<Exercise>(),
      requiresHipActivation: fields[6] as bool,
      keyFocusPoints: (fields[7] as List).cast<String>(),
      specialInstructions: fields[8] as String?,
      targetRPERange: fields[9] as String,
      estimatedDuration: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dayName)
      ..writeByte(2)
      ..write(obj.workoutName)
      ..writeByte(3)
      ..write(obj.weekNumber)
      ..writeByte(4)
      ..write(obj.blockPhase)
      ..writeByte(5)
      ..write(obj.exercises)
      ..writeByte(6)
      ..write(obj.requiresHipActivation)
      ..writeByte(7)
      ..write(obj.keyFocusPoints)
      ..writeByte(8)
      ..write(obj.specialInstructions)
      ..writeByte(9)
      ..write(obj.targetRPERange)
      ..writeByte(10)
      ..write(obj.estimatedDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
