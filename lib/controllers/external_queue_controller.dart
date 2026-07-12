import 'dart:async';
import 'dart:typed_data';
import 'package:ddnuvem/models/external_queue.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/google_drive/drive_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:flutter/material.dart';

class ExternalQueueController extends ChangeNotifier {
  final GoogleDriveAPI _googleDriveAPI;
  final SignInService _signInService;

  List<ExternalQueue> queues = [];
  String? assetsFolderId;
  String? queuesFileId;
  String? activeQueueId;
  bool loadingInitialState = true;

  ExternalQueueController(this._signInService, this._googleDriveAPI) {
    _initialize();
    _signInService.addListener(_signInListener);
  }

  _initialize() async {
    if (_signInService.isLoggedIn() && _signInService.isExternalUser()) {
      await _loadInfo();
      await _loadQueues();
    }
    loadingInitialState = false;
    notifyListeners();
  }

  @override
  dispose() {
    _signInService.removeListener(_signInListener);
    super.dispose();
  }

  _signInListener() async {
    if (_signInService.isLoggedIn() && _signInService.isExternalUser()) {
      loadingInitialState = true;
      notifyListeners();
      await _loadInfo();
      await _loadQueues();
      loadingInitialState = false;
      notifyListeners();
    } else {
      _signOutClear();
    }
  }

  _signOutClear() {
    queues = [];
    assetsFolderId = null;
    queuesFileId = null;
    activeQueueId = null;
  }

  _loadInfo() async {
    String? token = await _signInService.getAccessToken();
    assetsFolderId = await _googleDriveAPI
        .imageResource
        .getAssetsFolderId(token!);

    queuesFileId = await _googleDriveAPI
        .queueResource
        .getQueuesJsonId(token);
  }

  _loadQueues() async {
    String? token = await _signInService.getAccessToken();

    final json = await _googleDriveAPI
        .queueResource
        .get(token!, queuesFileId!);

    activeQueueId = json['activeQueue'];
    final List queuesJson = json['queues'] ?? [];

    queues = queuesJson
        .map((q) => ExternalQueue.fromMap(q))
        .toList();

    notifyListeners();
  }

  fetchQueueImages(Queue queue) async {
    String? token = await _signInService.getAccessToken();
    List<Future<Uint8List?>> futures = [];

    for (var image in queue.images) {
      if (image.data != null) {
        continue;
      }
      futures
          .add(_googleDriveAPI.imageResource
          .downloadImage(token!, image.path)
          .then((value) {
          image.data = value;
          image.uploaded = true;
          return value;
        },
      ));
    }

    await Future.wait(futures);
    return queue;
  }

  Future fetchImagesForShowview(ExternalQueue queue) async {
    String? token = await _signInService.getAccessToken();
    List<Future<Uint8List?>> futures = [];

    for (var image in queue.images) {
      if (image.data != null) continue;

      futures.add(
          _googleDriveAPI
              .imageResource
              .downloadImage(token!, image.path)
              .then((value) {
                image.data = value;
                return value;
              },
      ));
    }

    await Future.wait(futures).then((_) {
        notifyListeners();
      }
    );
  }

  createQueue(ExternalQueue queue) async {
    String? token = await _signInService.getAccessToken();
    try {
      List<Future> imagesFutures = [];
      for (var image in queue.images.where((i) => !i.uploaded)) {
        if (image.data != null) {
          debugPrint("Uploading image ${image.path}");
          imagesFutures.add(_googleDriveAPI.imageResource
              .uploadImage(token!, assetsFolderId!, image)
              .then(
                (fileId) {
                  image.uploaded = true;
                  image.path = fileId;
                },
          ));
        }
      }

      await Future.wait(imagesFutures);

      queues.add(queue);
      await _googleDriveAPI.queueResource.update(
          token!,
          queuesFileId!,
          activeQueueId!,
          queues
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Error creating queue: $e");
      rethrow;
    }
  }

  Future<String> updateQueue(ExternalQueue queue) async {
    try {
      String? token = await _signInService.getAccessToken();
      ExternalQueue oldQueue = queues.firstWhere((element) => element.id == queue.id);
      oldQueue.updated = false;
      notifyListeners();

      List<Future> imagesFutures = [];
      for (var image in queue.images.where((q) => !q.uploaded)) {
        if (image.data != null) {
          debugPrint("Uploading image ${image.path}");
          imagesFutures.add(_googleDriveAPI.imageResource
              .uploadImage(token!, assetsFolderId!, image)
              .then(
                (fileId) {
              image.uploaded = true;
              image.path = fileId;
            },
          ));
        }
      }

      for (var image in oldQueue.images.where((q) => q.uploaded)) {
        if (image.data != null && !queue.images.any((i) => i.path == image.path)) {
          debugPrint("Deleting image ${image.path}");
          imagesFutures.add(
              _googleDriveAPI
                  .imageResource
                  .deleteImage(token!, image.path)
          );
        }
      }

      await Future.wait(imagesFutures);

      queues.removeWhere((q) => q.id == queue.id);
      queues.add(queue);
      await _googleDriveAPI.queueResource.update(
          token!,
          queuesFileId!,
          activeQueueId!,
          queues
      );

      queue.updated = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating queue: $e");
      notifyListeners();
      return "Erro ao atualizar fila.";
    }

    return "Fila atualizada com sucesso!";
  }

  deleteQueue(ExternalQueue queue) async {
    String? token = await _signInService.getAccessToken();

    try {
      List<Future> imagesFutures = [];
      for (var image in queue.images) {
        if (image.data != null) {
          debugPrint("Deleting image ${image.path}");
          imagesFutures.add(
              _googleDriveAPI
                  .imageResource
                  .deleteImage(token!, image.path)
          );
        }
      }

      await Future.wait(imagesFutures);

      queues.removeWhere((q) => q.id == queue.id);
      await _googleDriveAPI.queueResource.update(
          token!,
          queuesFileId!,
          activeQueueId!,
          queues
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting queue: $e");
      rethrow;
    }
  }

  void updateCurrentQueue(String queueId) async {
    try {
      String? token = await _signInService.getAccessToken();

      await _googleDriveAPI.queueResource
          .update(token!, queuesFileId!, queueId, queues);

      activeQueueId = queueId;
      notifyListeners();
    } catch(e) {
      debugPrint("Error on activate queue: $e");
    }
  }

  int totalQueues() {
    return queues.length;
  }

  List<ExternalQueue> otherQueuesList() {
    return queues.where((q) => q.id != activeQueueId).toList();
  }

  ExternalQueue? getCurrentQueue() {
    return activeQueueId == "" ? null : queues.where((q) => q.id == activeQueueId).first;
  }
}
