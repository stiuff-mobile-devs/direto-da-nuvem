import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:flutter/cupertino.dart' hide Image;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/widgets.dart' hide Image;
import 'package:provider/provider.dart';

class ModerateQueueController extends ChangeNotifier {
  late String currentUserId;
  late QueueController queueController;
  BuildContext context;
  Queue queue;
  Uint8List? imageBytes;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool disposed = false;
  bool imagesLoaded = false;

  ModerateQueueController({required this.context, required this.queue}) {
    currentUserId = context.read<UserController>().currentUser!.id;
    queueController = context.read<QueueController>();
    queue.updatedBy = currentUserId;
    queue.updatedAt = DateTime.now();
    fetchImages();
  }

  @override
  void dispose() {
    disposed = true;
    debugPrint("ModeraQueueController disposed");
    super.dispose();
  }

  void fetchImages() async {
    imagesLoaded = false;
    notifyListeners();
    queue = await queueController.fetchQueueImages(queue);
    if (disposed) return;
    imagesLoaded = true;
    notifyListeners();
  }
}
