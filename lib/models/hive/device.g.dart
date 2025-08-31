// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceAdapter extends TypeAdapter<Device> {
  @override
  final int typeId = 0;

  @override
  Device read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Device(
      id: fields[0] as String,
      locale: fields[1] as String,
      description: fields[3] as String,
      groupId: fields[4] as String,
      registeredBy: fields[5] as String,
      registeredByEmail: fields[6] as String,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      updatedBy: fields[13] as String,
      brand: fields[7] as String?,
      model: fields[8] as String?,
      product: fields[9] as String?,
      device: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Device obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.locale)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.groupId)
      ..writeByte(5)
      ..write(obj.registeredBy)
      ..writeByte(6)
      ..write(obj.registeredByEmail)
      ..writeByte(7)
      ..write(obj.brand)
      ..writeByte(8)
      ..write(obj.model)
      ..writeByte(9)
      ..write(obj.product)
      ..writeByte(10)
      ..write(obj.device)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.updatedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
