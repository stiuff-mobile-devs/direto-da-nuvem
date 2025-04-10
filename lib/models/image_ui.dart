import 'dart:typed_data';

class ImageUI {
  String path;
  Uint8List? data;
  bool loading;
  bool uploaded;

  ImageUI(
      {required this.path,
      required this.data,
      this.loading = true,
      this.uploaded = true});
}
