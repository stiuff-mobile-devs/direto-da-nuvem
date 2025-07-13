import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageResource {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Uint8List?> fetchImageData(String url) async {
    return await _storage.ref().child(url).getData();
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