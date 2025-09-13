import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/image.dart' as model;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class ImageResource {
  static const collection = "images";
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<model.Image> _hiveBox = Hive.box<model.Image>(collection);

  Future<Uint8List?> fetchImageData(String path) async {
    try {
      model.Image? image = _getFromLocalDB(path);
      if (image == null) {
        return kIsWeb
            ? await _fetchForWeb(path)
            : await _fetchFromStorage(path);
      }
      return image.data;
    } catch (e) {
      debugPrint("Error on fetch image: $e");
      return null;
    }
  }

  Future<Uint8List?> _fetchForWeb(String path) async {
    try {
      final url = await _storage.ref(path).getDownloadURL();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (e) {
      debugPrint("Error on fetch image for web: $e");
      return null;
    }
  }

  Future<Uint8List?> _fetchFromStorage(String path) async {
    try {
      Uint8List? imageData = await _storage.ref().child(path).getData();
      if (imageData != null) {
        model.Image image = model.Image(
          path: path,
          data: imageData,
          uploaded: true,
        );
        _saveToLocalDB(image);
      }
      return imageData;
    } catch (e) {
      debugPrint("Error on fetch image from storage: $e");
      return null;
    }
  }

  uploadImage(model.Image image) async {
    try {
      await _storage.ref().child(image.path).putData(image.data!);
      await _firestore.collection(collection).doc(image.path).set(image.toMap());
      _saveToLocalDB(image);
    } catch (e) {
      debugPrint("Error on upload image ${image.path} to storage: $e.");
    }
  }

  // Hive
  _saveToLocalDB(model.Image image) {
    if (kIsWeb) return;
    try {
      _hiveBox.put(image.path, image);
    } catch (e) {
      debugPrint("Error on save image ${image.path} to Hive: $e.");
    }
  }

  // _deleteFromLocalDB(String path) {
  //   if (kIsWeb) return;
  //   try {
  //     _hiveBox.delete(path);
  //   } catch (e) {
  //     debugPrint("Error on delete image $path from Hive: $e.");
  //   }
  // }

  model.Image? _getFromLocalDB(String path) {
    if (kIsWeb) return null;
    try {
      return _hiveBox.get(path);
    } catch (e) {
      debugPrint("Error on get image $path from Hive: $e.");
      return null;
    }
  }
}