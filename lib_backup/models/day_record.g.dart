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
      totalTasks: fields[4] as int,
      completedTasks: fields[5] as int,
      earnedPoints: fields[6] as int,
      totalPoints: fields[7] as int,
      userRating: fields[3] as int,
      wentWell: fields[8] as String?,
      wentWrong: fields[9] as String?,
      notes: fields[10] as String?,
      isReviewed: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DayRecord obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.wentWell)
      ..writeByte(9)
      ..write(obj.wentWrong)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.isReviewed);
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
