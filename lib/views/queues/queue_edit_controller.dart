import 'dart:typed_data';

import 'package:ddnuvem/models/image_ui.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QueueEditController extends ChangeNotifier {
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  Queue queue;
  // List<ImageUI> images = [];
  Uint8List? imageBytes;
  bool hasChanged = false;
  final ImagePicker _picker = ImagePicker();
  bool disposed = false;

  QueueEditController({required this.diretoDaNuvemAPI, required this.queue}) {
    fetchImages();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex--;
    }
    final item = queue.images.removeAt(oldIndex);
    queue.images.insert(newIndex, item);
    notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    debugPrint("QueueEditController disposed");
    super.dispose();
  }

  void fetchImages() async {
    List<Future<Uint8List?>> futures = [];
    for (var image in queue.images) {
      if (image.data != null) {
        continue;
      }
      futures
          .add(diretoDaNuvemAPI.imageResource.fetchImageData(image.path).then(
        (value) {
          image.data = value;
          image.loading = false;
          return value;
        },
      ));
    }
    notifyListeners();
    await Future.wait(futures).then((_) {
      if (disposed) return;
      notifyListeners();
    });
    // List<Uint8List?> datas = await Future.wait(futures);
    // for (var data in datas) {
    //   if (data == null) continue;
    //   images.add(ImageUI(path: queue.images[images.length], data: data));
    // }
  }

  void pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    imageBytes = await pickedFile.readAsBytes();
    queue.images.add(ImageUI(
        path: pickedFile.name,
        data: imageBytes,
        loading: false,
        uploaded: false));
    if (disposed) return;
    notifyListeners();
  }

  void removeQueueImage(ImageUI image) {
    queue.images.remove(image);
    notifyListeners();
  }
}
