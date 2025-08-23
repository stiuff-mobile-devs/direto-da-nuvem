import 'dart:typed_data';

import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

class QueueViewController extends ChangeNotifier {
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  DeviceController deviceController;
  Queue? queue;
  QueueViewController(this.diretoDaNuvemAPI, this.deviceController) {
    queue = deviceController.currentQueue ?? deviceController.defaultQueue;
    deviceController.addListener(_updateQueue);
    fetchImages();
  }
  bool disposed = false;

  @override
  void dispose() {
    deviceController.removeListener(_updateQueue);
    disposed = true;
    debugPrint("QueueViewController disposed");
    super.dispose();
  }

  void _updateQueue() {
    final newQueue = deviceController.currentQueue;
    if (queue != newQueue) {
      queue = newQueue;
      fetchImages();
      notifyListeners();
    }
  }

  Future fetchImages() async {
    List<Future<Uint8List?>> futures = [];

    for (var image in queue!.images) {
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
    await Future.wait(futures).then(
      (_) {
        if (disposed) return;
        notifyListeners();
      },
    );
  }
}
