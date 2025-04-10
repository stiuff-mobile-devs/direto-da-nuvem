import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

class QueueController extends ChangeNotifier {
  final DiretoDaNuvemAPI diretoDaNuvemAPI;
  QueueController(this.diretoDaNuvemAPI);
  List<Queue> queues = [];
  Queue? selectedQueue;

  init() async {
    queues = await diretoDaNuvemAPI.queueResource.listAll();
    notifyListeners();
  }

  selectQueue(Queue queue) {
    selectedQueue = queue;
    notifyListeners();
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
          imagesFutures.add(diretoDaNuvemAPI.imageResource
              .uploadImage(image.path, image.data!)
              .then(
                (_) => image.uploaded = true,
              ));
        }
      }

      await Future.wait(imagesFutures);

      diretoDaNuvemAPI.queueResource
          .updateImageList(queue.id, queue.images.map((e) => e.path).toList());
      queue.updated = true;
      queues[queues.indexOf(oldqueue)] = queue;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating queue: $e");
      notifyListeners();
      return "Erro ao atualizar fila";
    }
    return "Fila atualizada com sucesso";
  }
}
