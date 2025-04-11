import 'dart:typed_data';

import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';

class QueueViewController extends ChangeNotifier {
  DiretoDaNuvemAPI diretoDaNuvemAPI;
  Queue queue;
  QueueViewController(this.diretoDaNuvemAPI, this.queue) {
    fetchImages();
  }
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    debugPrint("QueueViewController disposed");
    super.dispose();
  }

  void fetchImages() async {
    List<Future<Uint8List?>> futures = [];
    for (var image in queue.images) {
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
