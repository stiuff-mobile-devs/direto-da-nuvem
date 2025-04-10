import 'dart:typed_data';

class ImageUI {
  String path;
  Uint8List? data;
  bool loading;

  ImageUI({required this.path, required this.data, this.loading = true});
}
