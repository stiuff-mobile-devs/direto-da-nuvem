import 'dart:async';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

class QueueController extends ChangeNotifier {
  final DiretoDaNuvemAPI _diretoDaNuvemAPI;

  List<Queue> queues = [];

  StreamSubscription<List<Queue>>? _queuesSubscription;

  QueueController(this._diretoDaNuvemAPI);

  init() async {
    await _loadQueues();
    notifyListeners();
  }

  @override
  void dispose() {
    _queuesSubscription?.cancel();
    super.dispose();
  }

  _loadQueues() async {
    queues = await _diretoDaNuvemAPI.queueResource.listAll();
    Stream<List<Queue>>? queuesStream = _diretoDaNuvemAPI
        .queueResource.listAllStream();

    _queuesSubscription?.cancel();
    _queuesSubscription = queuesStream.listen((updatedQueues) {
      queues = updatedQueues;
      notifyListeners();
    });
  }

  Future<String> updateQueue(Queue queue) async {
    Queue oldqueue = queues.firstWhere((element) => element.id == queue.id);
    oldqueue.updated = false;
    notifyListeners();
    try {
      List<Future> imagesFutures = [];
      for (var image in queue.images.where((q) => !q.uploaded)) {
        if (image.data != null) {
          debugPrint("Uploading image ${image.path}");
          imagesFutures.add(_diretoDaNuvemAPI.imageResource
              .uploadImage(image.path, image.data!)
              .then(
                (_) => image.uploaded = true,
              ));
        }
      }

      await Future.wait(imagesFutures);

      await _diretoDaNuvemAPI.queueResource.update(queue);
      queue.updated = true;
      queues[queues.indexOf(oldqueue)] = queue;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating queue: $e");
      notifyListeners();
      return "Erro ao atualizar fila.";
    }
    return "Fila atualizada com sucesso!";
  }

  Future<String> saveQueue(Queue queue) async {
    queues.add(queue..updated = false);
    notifyListeners();
    try {
      List<Future> imagesFutures = [];
      for (var image in queue.images.where((q) => !q.uploaded)) {
        if (image.data != null) {
          debugPrint("Uploading image ${image.path}");
          imagesFutures.add(_diretoDaNuvemAPI.imageResource
              .uploadImage(image.path, image.data!)
              .then(
                (_) => image.uploaded = true,
              ));
        }
      }

      await Future.wait(imagesFutures);

      await _diretoDaNuvemAPI.queueResource.create(queue);
      queue.updated = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating queue: $e");
      queues.remove(queue);

      notifyListeners();
      return "Erro ao criar fila.";
    }
    return "Fila criada com sucesso!";
  }

  Future<String> deleteQueue(String id) async {
    await _diretoDaNuvemAPI.queueResource.delete(id);
    notifyListeners();
    return "Fila excluída com sucesso!";
  }

  Future deleteQueuesByGroup(String groupId) async {
    final filteredQueues = queues.where(
            (queue) => queue.groupId == groupId).toList();

    for (var queue in filteredQueues) {
      await deleteQueue(queue.id);
    }
  }
}
