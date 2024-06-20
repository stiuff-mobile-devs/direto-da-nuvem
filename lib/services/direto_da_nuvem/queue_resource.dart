import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/queue.dart';

class QueueResource {
  static const String collection = "queues"; 
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Queue?> get(String id) async {

    final doc = await _firestore.doc("$collection/$id").get();

    if (!doc.exists) {
      return null;
    }

    return Queue.fromMap(doc.data()!);
  }
}
