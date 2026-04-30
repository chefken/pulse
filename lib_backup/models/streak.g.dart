// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreakDataAdapter extends TypeAdapter<StreakData> {
  @override
  final int typeId = 4;

  @override
  StreakData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakData(
      currentStreak: fields[0] as int,
      longestStreak: fields[1] as int,
      totalActiveDays: fields[2] as int,
      totalDays: fields[3] as int,
      lastActiveDate: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StreakData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.longestStreak)
      ..writeByte(2)
      ..write(obj.totalActiveDays)
      ..writeByte(3)
      ..write(obj.totalDays)
      ..writeByte(4)
      ..write(obj.lastActiveDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
