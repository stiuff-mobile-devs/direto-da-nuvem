// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueueAdapter extends TypeAdapter<Queue> {
  @override
  final int typeId = 3;

  @override
  Queue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Queue(
      id: fields[0] as String,
      name: fields[2] as String,
      groupId: fields[1] as String,
      duration: fields[3] as int,
      animation: fields[4] as String,
      createdAt: fields[5] as DateTime,
      createdBy: fields[6] as String,
      images: (fields[7] as List).cast<ImageUI>(),
      updatedBy: fields[9] as String,
      updatedAt: fields[10] as DateTime,
    )..updated = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, Queue obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.animation)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.images)
      ..writeByte(8)
      ..write(obj.updated)
      ..writeByte(9)
      ..write(obj.updatedBy)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
