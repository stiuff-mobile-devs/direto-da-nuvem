import 'dart:typed_data';

import 'package:ddnuvem/models/image_ui.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QueueEditController extends ChangeNotifier {
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  Queue queue;
  List<ImageUI> images = [];
  Uint8List? imageBytes;
  bool hasChanged = false;
  final ImagePicker _picker = ImagePicker();

  QueueEditController({required this.diretoDaNuvemAPI, required this.queue}) {
    fetchImages();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex--;
    }
    final item = queue.images.removeAt(oldIndex);
    final itemImage = images.removeAt(oldIndex);
    images.insert(newIndex, itemImage);
    queue.images.insert(newIndex, item);
    notifyListeners();
  }

  void fetchImages() async {
    List<Future<Uint8List?>> futures = [];
    for (var imagePath in queue.images) {
      var image = ImageUI(path: imagePath, data: null);
      futures.add(diretoDaNuvemAPI.imageResource.fetchImageData(imagePath).then(
        (value) {
          image.data = value;
          image.loading = false;
          images.add(image);
          // notifyListeners();
          return value;
        },
      ));
    }
    notifyListeners();
    await Future.wait(futures).then((_) {
      notifyListeners();
    });
    // List<Uint8List?> datas = await Future.wait(futures);
    // for (var data in datas) {
    //   if (data == null) continue;
    //   images.add(ImageUI(path: queue.images[images.length], data: data));
    // }
  }

  void saveQueue() {}

  void pickImage() async {
    // Pick an image
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    imageBytes = await pickedFile.readAsBytes();
    images.add(ImageUI(path: pickedFile.path, data: imageBytes, loading: false));
    // queue.images.add(pickedFile.path);
    notifyListeners();
  }

  void removeQueueImage(ImageUI image) {
    images.remove(image);
    queue.images.remove(image.path);
    notifyListeners();
  }
}
