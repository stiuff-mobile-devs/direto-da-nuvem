import 'package:ddnuvem/models/queue.dart';

class QueueResource {
  Future<Queue> get(String id) async {
    return Queue(
        id: "",
        groupId: "1",
        duration: 1.0,
        animation: "ease",
        createdAt: DateTime.now(),
        createdBy: "fulano",
        images: [""]);
  }
}
