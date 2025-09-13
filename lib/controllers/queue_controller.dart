import 'dart:async';
import 'dart:typed_data';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:flutter/material.dart';

class QueueController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;
  final SignInService _signInService;

  List<Queue> queues = [];
  StreamSubscription<List<Queue>>? _queuesSubscription;

  QueueController(this._signInService, this._diretoDaNuvemAPI) {
    _initialize();
    _signInService.addListener(_signInListener);
  }

  _initialize() async {
    if (_signInService.isLoggedIn()) {
      await _loadQueues();
    }
  }

  @override
  dispose() {
    _queuesSubscription?.cancel();
    _signInService.removeListener(_signInListener);
    super.dispose();
  }

  _signInListener() async {
    if (_signInService.isLoggedIn()) {
      await _loadQueues();
    } else {
      _signOutClear();
    }
  }

  _signOutClear() {
    queues = [];
    _queuesSubscription?.cancel();
  }

  _loadQueues() async {
    queues = await _diretoDaNuvemAPI.queueResource.getAll();
    Stream<List<Queue>>? queuesStream = _diretoDaNuvemAPI
        .queueResource.getAllStream();

    _queuesSubscription?.cancel();
    _queuesSubscription = queuesStream.listen((updatedQueues) {
      queues = updatedQueues;
      notifyListeners();
    },
    onError: (e) {
      debugPrint("Erro ao escutar stream de filas: $e");
    });

    notifyListeners();
  }

  Future<String> updateQueue(Queue queue) async {
    Queue oldQueue = queues.firstWhere((element) => element.id == queue.id);
    oldQueue.updated = false;
    notifyListeners();

    try {
      List<Future> imagesFutures = [];
      for (var image in queue.images.where((q) => !q.uploaded)) {
        if (image.data != null) {
          debugPrint("Uploading image ${image.path}");
          imagesFutures.add(_diretoDaNuvemAPI.imageResource
              .uploadImage(image)
              .then(
                (_) => image.uploaded = true,
          ));
        }
      }

      await Future.wait(imagesFutures);

      await _diretoDaNuvemAPI.queueResource.update(queue);
      queue.updated = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating queue: $e");
      notifyListeners();
      return "Erro ao atualizar fila.";
    }

    return "Fila atualizada com sucesso!";
  }

  createQueue(Queue queue) async {
    try {
      List<Future> imagesFutures = [];
      for (var image in queue.images.where((i) => !i.uploaded)) {
        if (image.data != null) {
          debugPrint("Uploading image ${image.path}");
          imagesFutures.add(_diretoDaNuvemAPI.imageResource
              .uploadImage(image)
              .then(
                (_) => image.uploaded = true,
              ));
        }
      }

      await Future.wait(imagesFutures);

      await _diretoDaNuvemAPI.queueResource.create(queue);
    } catch (e) {
      debugPrint("Error updating queue: $e");
      rethrow;
    }
  }

  deleteQueue(String id) async {
    try {
      await _diretoDaNuvemAPI.queueResource.delete(id);
    } catch (e) {
      rethrow;
    }
  }

  deleteQueuesByGroup(String groupId) async {
    final filteredQueues = queues.where(
            (queue) => queue.groupId == groupId).toList();

    for (var queue in filteredQueues) {
      await deleteQueue(queue.id);
    }
  }

  fetchQueueImages(Queue queue) async {
    List<Future<Uint8List?>> futures = [];
    for (var image in queue.images) {
      if (image.data != null) {
        continue;
      }
      futures
          .add(_diretoDaNuvemAPI.imageResource.fetchImageData(image.path).then(
            (value) {
          image.data = value;
          image.uploaded = true;
          return value;
        },
      ));
    }

    await Future.wait(futures);
    return queue;
  }

  bool checkPendingQueuesByGroup(String groupId) {
    final filteredQueues = queues.where(
            (queue) => queue.groupId == groupId).toList();

    for (var queue in filteredQueues) {
      if (queue.status == QueueStatus.pending) {
        return true;
      }
    }

    return false;
  }
}
