// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user_privileges.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPrivilegesAdapter extends TypeAdapter<UserPrivileges> {
  @override
  final int typeId = 5;

  @override
  UserPrivileges read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPrivileges(
      isAdmin: fields[0] as bool,
      isSuperAdmin: fields[1] as bool,
      isInstaller: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPrivileges obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isAdmin)
      ..writeByte(1)
      ..write(obj.isSuperAdmin)
      ..writeByte(2)
      ..write(obj.isInstaller);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPrivilegesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
