import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class ImageResource {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Uint8List?> fetchImageData(String url) async {
    return await _storage.ref().child(url).getData();
  }
}