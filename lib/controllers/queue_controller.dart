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
}