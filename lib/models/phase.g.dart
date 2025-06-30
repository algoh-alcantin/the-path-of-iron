// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhaseAdapter extends TypeAdapter<Phase> {
  @override
  final int typeId = 25;

  @override
  Phase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Phase(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as PhaseType,
      durationWeeks: fields[4] as int,
      workoutTemplates: (fields[5] as List).cast<Workout>(),
      characteristics: fields[6] as PhaseCharacteristics,
      phaseParameters: (fields[7] as Map).cast<String, dynamic>(),
      sequenceNumber: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Phase obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.durationWeeks)
      ..writeByte(5)
      ..write(obj.workoutTemplates)
      ..writeByte(6)
      ..write(obj.characteristics)
      ..writeByte(7)
      ..write(obj.phaseParameters)
      ..writeByte(8)
      ..write(obj.sequenceNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhaseCharacteristicsAdapter extends TypeAdapter<PhaseCharacteristics> {
  @override
  final int typeId = 27;

  @override
  PhaseCharacteristics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhaseCharacteristics(
      volumeMultiplier: fields[0] as double,
      intensityMultiplier: fields[1] as double,
      frequencyMultiplier: fields[2] as double,
      exerciseEmphasis: (fields[3] as Map).cast<String, double>(),
      primaryGoals: (fields[4] as List).cast<String>(),
      specialFeatures: (fields[5] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PhaseCharacteristics obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.volumeMultiplier)
      ..writeByte(1)
      ..write(obj.intensityMultiplier)
      ..writeByte(2)
      ..write(obj.frequencyMultiplier)
      ..writeByte(3)
      ..write(obj.exerciseEmphasis)
      ..writeByte(4)
      ..write(obj.primaryGoals)
      ..writeByte(5)
      ..write(obj.specialFeatures);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseCharacteristicsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhaseTypeAdapter extends TypeAdapter<PhaseType> {
  @override
  final int typeId = 26;

  @override
  PhaseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PhaseType.accumulation;
      case 1:
        return PhaseType.intensification;
      case 2:
        return PhaseType.peaking;
      case 3:
        return PhaseType.deload;
      case 4:
        return PhaseType.testing;
      default:
        return PhaseType.accumulation;
    }
  }

  @override
  void write(BinaryWriter writer, PhaseType obj) {
    switch (obj) {
      case PhaseType.accumulation:
        writer.writeByte(0);
        break;
      case PhaseType.intensification:
        writer.writeByte(1);
        break;
      case PhaseType.peaking:
        writer.writeByte(2);
        break;
      case PhaseType.deload:
        writer.writeByte(3);
        break;
      case PhaseType.testing:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
