import 'dart:typed_data';

import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

class QueueViewController extends ChangeNotifier {
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  DeviceController deviceController;
  Queue? queue;
  bool loadingImages = false;
  bool registeredDevice = false;
  bool disposed = false;

  QueueViewController(this.diretoDaNuvemAPI, this.deviceController) {
    _getQueue();
    registeredDevice = deviceController.isRegistered;
    deviceController.addListener(_updateQueue);
  }

  @override
  void dispose() {
    deviceController.removeListener(_updateQueue);
    disposed = true;
    debugPrint("QueueViewController disposed");
    super.dispose();
  }

  _getQueue() async {
    loadingImages = true;
    notifyListeners();
    final currentQueue = deviceController.currentQueue;
    if (currentQueue != null && currentQueue.status == QueueStatus.approved) {
      queue = currentQueue;
    } else {
      queue = await deviceController.getDefaultQueue();
    }
    await _fetchImages();
    loadingImages = false;
    notifyListeners();
  }

  _updateQueue() async {
    final newQueue = deviceController.currentQueue;
    if (newQueue != queue) {
      await _getQueue();
    }
  }

  // Future _fetchImages() async {
  //   for (var image in queue!.images) {
  //     if (image.data != null) continue;
  //
  //     final value = await diretoDaNuvemAPI.imageResource.fetchImageData(
  //         image.path);
  //     image.data = value;
  //     image.loading = false;
  //
  //     if (disposed) return;
  //     notifyListeners();
  //   }
  // }

  Future _fetchImages() async {
    List<Future<Uint8List?>> futures = [];

    for (var image in queue!.images) {
      if (image.data != null) continue;

      futures
          .add(diretoDaNuvemAPI.imageResource.fetchImageData(image.path).then(
            (value) {
          image.data = value;
          image.loading = false;
          return value;
        },
      ));
    }

    await Future.wait(futures).then(
          (_) {
        if (disposed) return;
        notifyListeners();
      },
    );
  }
}
