// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_max.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingMaxAdapter extends TypeAdapter<TrainingMax> {
  @override
  final int typeId = 0;

  @override
  TrainingMax read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingMax(
      id: fields[0] as String,
      exercise: fields[1] as String,
      weight: fields[2] as double,
      lastTested: fields[3] as DateTime,
      recentResults: (fields[4] as List).cast<AMRAPResult>(),
      isActive: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingMax obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exercise)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.lastTested)
      ..writeByte(4)
      ..write(obj.recentResults)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingMaxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AMRAPResultAdapter extends TypeAdapter<AMRAPResult> {
  @override
  final int typeId = 1;

  @override
  AMRAPResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AMRAPResult(
      id: fields[0] as String,
      weight: fields[1] as double,
      reps: fields[2] as int,
      date: fields[3] as DateTime,
      rpe: fields[4] as double,
      notes: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AMRAPResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.rpe)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AMRAPResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
