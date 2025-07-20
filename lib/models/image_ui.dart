import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'image_ui.g.dart';

@HiveType(typeId: 2)
class ImageUI extends HiveObject {
  @HiveField(0)
  String path;
  @HiveField(1)
  Uint8List? data;
  @HiveField(2)
  bool loading;
  @HiveField(3)
  bool uploaded;

  ImageUI({
    required this.path,
    required this.data,
    this.loading = true,
    this.uploaded = true
  });
}
