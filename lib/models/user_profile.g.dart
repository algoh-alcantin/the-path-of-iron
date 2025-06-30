// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 12;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      currentWeek: fields[1] as int,
      currentBlock: fields[2] as String,
      currentMaxes: (fields[3] as Map).cast<String, int>(),
      targetMaxes: (fields[4] as Map).cast<String, int>(),
      hipIssues: fields[5] as bool,
      hipSide: fields[6] as String,
      programStartDate: fields[7] as DateTime,
      completedWorkouts: (fields[8] as List).cast<String>(),
      trainingExperience: fields[9] as int,
      experienceLevel: fields[10] as String,
      trainingFrequency: fields[11] as int,
      isActive: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.currentWeek)
      ..writeByte(2)
      ..write(obj.currentBlock)
      ..writeByte(3)
      ..write(obj.currentMaxes)
      ..writeByte(4)
      ..write(obj.targetMaxes)
      ..writeByte(5)
      ..write(obj.hipIssues)
      ..writeByte(6)
      ..write(obj.hipSide)
      ..writeByte(7)
      ..write(obj.programStartDate)
      ..writeByte(8)
      ..write(obj.completedWorkouts)
      ..writeByte(9)
      ..write(obj.trainingExperience)
      ..writeByte(10)
      ..write(obj.experienceLevel)
      ..writeByte(11)
      ..write(obj.trainingFrequency)
      ..writeByte(12)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
