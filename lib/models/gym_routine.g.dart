// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_routine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GymDayAdapter extends TypeAdapter<GymDay> {
  @override
  final int typeId = 5;

  @override
  GymDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymDay(
      weekday: fields[0] as String,
      muscleGroup: fields[1] as String,
      isRest: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GymDay obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.weekday)
      ..writeByte(1)
      ..write(obj.muscleGroup)
      ..writeByte(2)
      ..write(obj.isRest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GymSessionAdapter extends TypeAdapter<GymSession> {
  @override
  final int typeId = 6;

  @override
  GymSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymSession(
      dateKey: fields[0] as String,
      completed: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GymSession obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
