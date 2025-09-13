import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'image.g.dart';

@HiveType(typeId: 2)
class Image extends HiveObject {
  @HiveField(0)
  String path;
  @HiveField(1)
  Uint8List? data;
  @HiveField(2)
  DateTime? createdAt;
  @HiveField(3)
  String? createdBy;
  @HiveField(4)
  bool uploaded;

  Image({
    required this.path,
    this.createdAt,
    this.createdBy,
    this.data,
    this.uploaded = false
  });

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt,
      'created_by': createdBy,
      'path': path,
    };
  }
}
