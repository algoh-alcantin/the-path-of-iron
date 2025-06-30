// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgramAdapter extends TypeAdapter<Program> {
  @override
  final int typeId = 20;

  @override
  Program read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Program(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ProgramType,
      phases: (fields[4] as List).cast<Phase>(),
      metadata: fields[5] as ProgramMetadata,
      progressionLogic: fields[6] as ProgressionLogic,
      requiredEquipment: (fields[7] as List).cast<String>(),
      difficulty: fields[8] as DifficultyLevel,
      estimatedDuration: fields[9] as ProgramDuration,
    );
  }

  @override
  void write(BinaryWriter writer, Program obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.phases)
      ..writeByte(5)
      ..write(obj.metadata)
      ..writeByte(6)
      ..write(obj.progressionLogic)
      ..writeByte(7)
      ..write(obj.requiredEquipment)
      ..writeByte(8)
      ..write(obj.difficulty)
      ..writeByte(9)
      ..write(obj.estimatedDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgramMetadataAdapter extends TypeAdapter<ProgramMetadata> {
  @override
  final int typeId = 23;

  @override
  ProgramMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramMetadata(
      author: fields[0] as String,
      version: fields[1] as String,
      createdDate: fields[2] as DateTime,
      tags: (fields[3] as List).cast<String>(),
      sourceUrl: fields[4] as String?,
      customFields: (fields[5] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgramMetadata obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.author)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.createdDate)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.sourceUrl)
      ..writeByte(5)
      ..write(obj.customFields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgramDurationAdapter extends TypeAdapter<ProgramDuration> {
  @override
  final int typeId = 24;

  @override
  ProgramDuration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramDuration(
      weeks: fields[0] as int,
      days: fields[1] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProgramDuration obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weeks)
      ..writeByte(1)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramDurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgramTypeAdapter extends TypeAdapter<ProgramType> {
  @override
  final int typeId = 21;

  @override
  ProgramType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProgramType.powerlifting;
      case 1:
        return ProgramType.strengthBuilding;
      case 2:
        return ProgramType.hypertrophy;
      case 3:
        return ProgramType.peaking;
      case 4:
        return ProgramType.rehabilitation;
      default:
        return ProgramType.powerlifting;
    }
  }

  @override
  void write(BinaryWriter writer, ProgramType obj) {
    switch (obj) {
      case ProgramType.powerlifting:
        writer.writeByte(0);
        break;
      case ProgramType.strengthBuilding:
        writer.writeByte(1);
        break;
      case ProgramType.hypertrophy:
        writer.writeByte(2);
        break;
      case ProgramType.peaking:
        writer.writeByte(3);
        break;
      case ProgramType.rehabilitation:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyLevelAdapter extends TypeAdapter<DifficultyLevel> {
  @override
  final int typeId = 22;

  @override
  DifficultyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DifficultyLevel.beginner;
      case 1:
        return DifficultyLevel.intermediate;
      case 2:
        return DifficultyLevel.advanced;
      case 3:
        return DifficultyLevel.elite;
      default:
        return DifficultyLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, DifficultyLevel obj) {
    switch (obj) {
      case DifficultyLevel.beginner:
        writer.writeByte(0);
        break;
      case DifficultyLevel.intermediate:
        writer.writeByte(1);
        break;
      case DifficultyLevel.advanced:
        writer.writeByte(2);
        break;
      case DifficultyLevel.elite:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
