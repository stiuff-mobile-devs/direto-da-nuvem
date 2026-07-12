import 'dart:typed_data';
import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/external_queue_controller.dart';
import 'package:ddnuvem/models/external_queue.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/animation.dart' as model;
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

import '../../../services/google_drive/drive_service.dart';

class ExternalQueueViewController extends ChangeNotifier {
  ExternalQueueController externalQueueController;
  DeviceController deviceController;
  ExternalQueue? queue;
  late model.Animation animation;
  bool loadingImages = false;
  bool disposed = false;

  ExternalQueueViewController(this.externalQueueController, this.deviceController) {
    _getQueue();
    _requestPermission();
    externalQueueController.addListener(_updateQueue);
  }

  @override
  void dispose() {
    externalQueueController.removeListener(_updateQueue);
    disposed = true;
    debugPrint("ExternalQueueViewController disposed");
    super.dispose();
  }

  _getQueue() async {
    loadingImages = true;
    notifyListeners();
    queue = externalQueueController.getCurrentQueue();
    if (queue != null) {
      animation = model.Animation.getAnimation(queue!.animation);
      await _fetchImages();
    }
    loadingImages = false;
    notifyListeners();
  }

  Future _fetchImages() async {
    await externalQueueController.fetchImagesForShowview(queue!);
  }

  _updateQueue() async {
    final newQueue = externalQueueController.getCurrentQueue();
    if (newQueue != queue) {
      await _getQueue();
    }
  }

  _requestPermission() async {
    await deviceController.requestPermissions();
  }
}
