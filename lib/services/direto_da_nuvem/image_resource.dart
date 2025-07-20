import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/image.dart';
import 'package:ddnuvem/models/image_ui.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';

class ImageResource {
  static const collection = "images";
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<ImageUI> _box = Hive.box<ImageUI>(collection);

  Future<Uint8List?> fetchImageData(String url) async {
    try {
      final image = _box.values.firstWhere((image) => image.path == url);
      return image.data;
    } catch (e) {
      return await _fetchImageFromStorage(url);
    }
  }

  Future<Uint8List?> _fetchImageFromStorage(String url) async {
    Uint8List? imageData = await _storage.ref().child(url).getData();
    if (imageData != null) {
      ImageUI newImage = ImageUI(
        path: url,
        data: imageData,
        loading: false,
        uploaded: true,
      );

      _box.put(newImage.path, newImage);
      return imageData;
    }
    return null;
  }

  Future<String> uploadImage(String path, Uint8List data) async {
    _firestore.collection("images").doc(path).set(Image(
      path: path,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toMap());
    final ref = _storage.ref().child(path);
    await ref.putData(data);
    return ref.fullPath;
  }
}