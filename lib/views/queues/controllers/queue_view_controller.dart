import 'dart:typed_data';
import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/animation.dart' as model;
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

class QueueViewController extends ChangeNotifier {
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  DeviceController deviceController;
  ConnectionService connectionService;
  Queue? queue;
  late model.Animation animation;
  bool loadingImages = false;
  bool registeredDevice = false;
  bool isConnected = false;
  bool disposed = false;

  QueueViewController(this.diretoDaNuvemAPI, this.deviceController, this.connectionService) {
    _getQueue();
    _requestPermission();
    registeredDevice = deviceController.isRegistered;
    isConnected = connectionService.connectionStatus;
    deviceController.addListener(_updateQueue);
    connectionService.addListener(_updateConnectionStatus);
  }

  @override
  void dispose() {
    deviceController.removeListener(_updateQueue);
    connectionService.removeListener(_updateConnectionStatus);
    disposed = true;
    debugPrint("QueueViewController disposed");
    super.dispose();
  }

  void _updateConnectionStatus() {
    if (isConnected != connectionService.connectionStatus) {
      isConnected = connectionService.connectionStatus;
      notifyListeners();
    }
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
    animation = model.Animation.getAnimation(queue!.animation);
    await _fetchImages();
    loadingImages = false;
    notifyListeners();
  }

  _requestPermission() async {
    await deviceController.requestPermissions();
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
