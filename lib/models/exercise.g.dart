// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 13;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      name: fields[0] as String,
      sets: fields[1] as int,
      reps: fields[2] as dynamic,
      weight: fields[3] as dynamic,
      type: fields[4] as String,
      cues: (fields[5] as List).cast<String>(),
      isUnilateral: fields[6] as bool,
      muscleGroup: fields[7] as String,
      equipment: fields[8] as String?,
      restPeriod: fields[9] as int?,
      rpeTarget: fields[10] as String?,
      specialInstructions: fields[11] as String?,
      requiresHipActivation: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.cues)
      ..writeByte(6)
      ..write(obj.isUnilateral)
      ..writeByte(7)
      ..write(obj.muscleGroup)
      ..writeByte(8)
      ..write(obj.equipment)
      ..writeByte(9)
      ..write(obj.restPeriod)
      ..writeByte(10)
      ..write(obj.rpeTarget)
      ..writeByte(11)
      ..write(obj.specialInstructions)
      ..writeByte(12)
      ..write(obj.requiresHipActivation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
