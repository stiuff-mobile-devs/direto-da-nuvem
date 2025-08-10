import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';

class QueueResource {
  static const collection = "queues";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Queue> _hiveBox = Hive.box<Queue>(collection);

  Future<List<Queue>> listAll() async {
    List<Queue> queues = [];

    if (await hasInternetConnection()) {
      final list = await _firestore.collection(collection).get();

      for (var doc in list.docs) {
        Queue queue = Queue.fromMap(doc.id, doc.data());
        queues.add(queue);
        _hiveBox.put(queue.id, queue);
      }
    } else {
      queues = _hiveBox.values.toList();
    }

    return queues;
  }

  Future<Queue?> get(String id) async {
    if (await hasInternetConnection()) {
      var doc = await _firestore.doc("$collection/$id").get();
      if (!doc.exists) {
        return null;
      }
      return Queue.fromMap(doc.id, doc.data()!);
    } else {
      return _hiveBox.get(id);
    }
  }

  Future create(Queue queue) async {
    var doc = await _firestore.collection(collection).add(queue.toMap());
    queue.id = doc.id;
    _hiveBox.put(queue.id, queue);
  }

  Future update(Queue queue) async {
    var doc = _firestore.collection(collection).doc(queue.id);
    await doc.update(queue.toMap());
    _hiveBox.put(queue.id, queue);
  }

  Stream<Queue?> getStream(String id) {
    var doc = _firestore.doc("$collection/$id").snapshots();
    return doc.map((event) => Queue.fromMap(event.id, event.data()!));
  }

  Stream<List<Queue>> listAllStream() {
    var l = _firestore.collection(QueueResource.collection).snapshots();
    return l.map((event) {
      List<Queue> queues = [];

      for (var doc in event.docs) {
        Queue queue = Queue.fromMap(doc.id, doc.data());
        queues.add(queue);
      }
      return queues;
    });
  }
}
