import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';

class QueueResource {
  static const collection = "queues";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Queue> _box = Hive.box<Queue>(collection);

  Future<List<Queue>> listAll() async {
    List<Queue> queues = [];

    if (await hasInternetConnection()) {
      queues = await _getAllFromFirestore();

      for (var queue in queues) {
        if (!_box.containsKey(queue.id)) {
          _box.put(queue.id, queue);
        }
      }
    } else {
      queues = await _getAllFromLocal();
    }

    return queues;
  }

  Future<List<Queue>> _getAllFromFirestore() async {
    var l = await _firestore.collection(QueueResource.collection).get();

    List<Queue> queues = [];

    for (var doc in l.docs) {
      Queue queue = Queue.fromMap(doc.data());
      queue.id = doc.id;
      queues.add(queue);
    }

    return queues;
  }

  Future<List<Queue>> _getAllFromLocal() async {
    List<Queue> queues = _box.values.toList();
    return queues;
  }

  Stream<List<Queue>> listAllStream() {
    var l = _firestore.collection(QueueResource.collection).snapshots();
    return l.map((event) {
      List<Queue> queues = [];

      for (var doc in event.docs) {
        Queue queue = Queue.fromMap(doc.data());
        queue.id = doc.id;
        queues.add(queue);
      }
      return queues;
    });
  }

  Future<Queue?> get(String id) async {
    if (await hasInternetConnection()) {
      var doc = await _firestore.doc("$collection/$id").get();
      if (!doc.exists) {
        return null;
      }
      return Queue.fromMap(doc.data()!)..id = doc.id;
    } else {
      Queue? queue = _box.get(id);
      return queue;
    }
  }

  Stream<Queue?> getStream(String id) {
    var doc = _firestore.doc("$collection/$id").snapshots();
    return doc.map((event) => Queue.fromMap(event.data()!)..id = event.id);
  }

  Future create(Queue queue) async {
    var doc = await _firestore.collection(collection).add(queue.toMap());
    queue.id = doc.id;
  }

  Future update(Queue queue) async {
    var doc = _firestore.collection(collection).doc(queue.id);
    await doc.update(queue.toMap());
  }
}
