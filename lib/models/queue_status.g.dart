// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueueStatusAdapter extends TypeAdapter<QueueStatus> {
  @override
  final int typeId = 6;

  @override
  QueueStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QueueStatus.pending;
      case 1:
        return QueueStatus.approved;
      case 2:
        return QueueStatus.rejected;
      default:
        return QueueStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, QueueStatus obj) {
    switch (obj) {
      case QueueStatus.pending:
        writer.writeByte(0);
        break;
      case QueueStatus.approved:
        writer.writeByte(1);
        break;
      case QueueStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
