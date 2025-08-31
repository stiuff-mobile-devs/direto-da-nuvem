// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../image_ui.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageUIAdapter extends TypeAdapter<ImageUI> {
  @override
  final int typeId = 2;

  @override
  ImageUI read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageUI(
      path: fields[0] as String,
      data: fields[1] as Uint8List?,
      loading: fields[2] as bool,
      uploaded: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ImageUI obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.loading)
      ..writeByte(3)
      ..write(obj.uploaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUIAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
