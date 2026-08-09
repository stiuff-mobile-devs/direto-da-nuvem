import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/external_queue_controller.dart';
import 'package:ddnuvem/models/external_queue.dart';
import 'package:ddnuvem/models/animation.dart' as model;
import 'package:flutter/material.dart';
import '../../../services/connection_service.dart';

class ExternalQueueViewController extends ChangeNotifier {
  ExternalQueueController externalQueueController;
  DeviceController deviceController;
  ConnectionService connectionService;
  ExternalQueue? queue;
  late model.Animation animation;
  bool loadingImages = false;
  bool isConnected = false;
  bool disposed = false;

  ExternalQueueViewController(this.externalQueueController, this.deviceController, this.connectionService) {
    _getQueue();
    _requestPermission();
    isConnected = connectionService.connectionStatus;
    externalQueueController.addListener(_updateQueue);
    connectionService.addListener(_updateConnectionStatus);
  }

  @override
  void dispose() {
    externalQueueController.removeListener(_updateQueue);
    disposed = true;
    debugPrint("ExternalQueueViewController disposed");
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
