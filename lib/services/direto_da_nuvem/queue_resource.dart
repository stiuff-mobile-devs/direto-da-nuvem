import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/queue.dart';

class QueueResource {
  static const collection = "queues";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Queue>> listAll() async {
    var l = await _firestore.collection(QueueResource.collection).get();

    List<Queue> queues = [];

    for (var doc in l.docs) {
      Queue queue = Queue.fromMap(doc.data());
      queues.add(queue);
    }
    return queues;
  }

  Future<Queue?> get(String id) async {
    var doc = await _firestore.doc("$collection/$id").get();
    if (!doc.exists) {
      return null;
    }
    return Queue.fromMap(doc.data()!);
  }

  Future create(Queue queue) async {
    var doc = await _firestore.collection(collection).add(queue.toMap());
  }
}
