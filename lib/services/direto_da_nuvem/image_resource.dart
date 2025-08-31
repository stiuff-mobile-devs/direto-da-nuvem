import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/image.dart';
import 'package:ddnuvem/models/image_ui.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';

class ImageResource {
  static const collection = "images";
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<ImageUI> _hiveBox = Hive.box<ImageUI>(collection);

  Future<Uint8List?> fetchImageData(String url) async {
    ImageUI? image = _hiveBox.get(url);

    if (image != null) {
      return image.data;
    } else if (await ConnectionService.isConnected()) {
      return await _fetchImageFromStorage(url);
    }

    return null;
  }

  Future<Uint8List?> _fetchImageFromStorage(String url) async {
    Uint8List? imageData = await _storage.ref().child(url).getData();
    if (imageData != null) {
      ImageUI image = ImageUI(
        path: url,
        data: imageData,
      );

      _hiveBox.put(image.path, image);
      return imageData;
    }

    return null;
  }

  Future<String> uploadImage(String path, Uint8List data) async {
    _firestore.collection(collection).doc(path).set(Image(
      path: path,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toMap());
    final ref = _storage.ref().child(path);
    await ref.putData(data);

    ImageUI imageUI = ImageUI(
      path: path,
      data: data,
    );
    _hiveBox.put(path, imageUI);

    return ref.fullPath;
  }
}