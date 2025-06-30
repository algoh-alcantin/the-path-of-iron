// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression_logic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressionLogicAdapter extends TypeAdapter<ProgressionLogic> {
  @override
  final int typeId = 28;

  @override
  ProgressionLogic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressionLogic(
      type: fields[0] as ProgressionType,
      parameters: (fields[1] as Map).cast<String, dynamic>(),
      rules: (fields[2] as List).cast<ProgressionRule>(),
      autoregulationRules:
          (fields[3] as Map).cast<String, AutoregulationRule>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgressionLogic obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.parameters)
      ..writeByte(2)
      ..write(obj.rules)
      ..writeByte(3)
      ..write(obj.autoregulationRules);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionLogicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgressionRuleAdapter extends TypeAdapter<ProgressionRule> {
  @override
  final int typeId = 30;

  @override
  ProgressionRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressionRule(
      id: fields[0] as String,
      name: fields[1] as String,
      applicableExercises: (fields[2] as List).cast<String>(),
      formula: fields[3] as ProgressionFormula,
      parameters: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgressionRule obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.applicableExercises)
      ..writeByte(3)
      ..write(obj.formula)
      ..writeByte(4)
      ..write(obj.parameters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgressionFormulaAdapter extends TypeAdapter<ProgressionFormula> {
  @override
  final int typeId = 31;

  @override
  ProgressionFormula read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressionFormula(
      type: fields[0] as FormulaType,
      expression: fields[1] as String,
      constants: (fields[2] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgressionFormula obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.expression)
      ..writeByte(2)
      ..write(obj.constants);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionFormulaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AutoregulationRuleAdapter extends TypeAdapter<AutoregulationRule> {
  @override
  final int typeId = 33;

  @override
  AutoregulationRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AutoregulationRule(
      trigger: fields[0] as String,
      conditions: (fields[1] as Map).cast<String, dynamic>(),
      adjustments: (fields[2] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AutoregulationRule obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.trigger)
      ..writeByte(1)
      ..write(obj.conditions)
      ..writeByte(2)
      ..write(obj.adjustments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoregulationRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgressionTypeAdapter extends TypeAdapter<ProgressionType> {
  @override
  final int typeId = 29;

  @override
  ProgressionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProgressionType.linear;
      case 1:
        return ProgressionType.periodized;
      case 2:
        return ProgressionType.autoregulated;
      case 3:
        return ProgressionType.undulating;
      case 4:
        return ProgressionType.block;
      default:
        return ProgressionType.linear;
    }
  }

  @override
  void write(BinaryWriter writer, ProgressionType obj) {
    switch (obj) {
      case ProgressionType.linear:
        writer.writeByte(0);
        break;
      case ProgressionType.periodized:
        writer.writeByte(1);
        break;
      case ProgressionType.autoregulated:
        writer.writeByte(2);
        break;
      case ProgressionType.undulating:
        writer.writeByte(3);
        break;
      case ProgressionType.block:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FormulaTypeAdapter extends TypeAdapter<FormulaType> {
  @override
  final int typeId = 32;

  @override
  FormulaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FormulaType.percentage;
      case 1:
        return FormulaType.linear;
      case 2:
        return FormulaType.exponential;
      case 3:
        return FormulaType.custom;
      default:
        return FormulaType.percentage;
    }
  }

  @override
  void write(BinaryWriter writer, FormulaType obj) {
    switch (obj) {
      case FormulaType.percentage:
        writer.writeByte(0);
        break;
      case FormulaType.linear:
        writer.writeByte(1);
        break;
      case FormulaType.exponential:
        writer.writeByte(2);
        break;
      case FormulaType.custom:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormulaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
