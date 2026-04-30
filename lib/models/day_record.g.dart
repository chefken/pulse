// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayRecordAdapter extends TypeAdapter<DayRecord> {
  @override
  final int typeId = 3;

  @override
  DayRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayRecord(
      id: fields[0] as String,
      dateKey: fields[1] as String,
      disciplineScore: fields[2] as double,
      userRating: fields[3] as int,
      totalTasks: fields[4] as int,
      completedTasks: fields[5] as int,
      earnedPoints: fields[6] as int,
      totalPoints: fields[7] as int,
      isReviewed: fields[8] as bool,
      completedHabitTitles: (fields[9] as List?)?.cast<String>(),
      completedTaskTitles: (fields[10] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DayRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateKey)
      ..writeByte(2)
      ..write(obj.disciplineScore)
      ..writeByte(3)
      ..write(obj.userRating)
      ..writeByte(4)
      ..write(obj.totalTasks)
      ..writeByte(5)
      ..write(obj.completedTasks)
      ..writeByte(6)
      ..write(obj.earnedPoints)
      ..writeByte(7)
      ..write(obj.totalPoints)
      ..writeByte(8)
      ..write(obj.isReviewed)
      ..writeByte(9)
      ..write(obj.completedHabitTitles)
      ..writeByte(10)
      ..write(obj.completedTaskTitles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
