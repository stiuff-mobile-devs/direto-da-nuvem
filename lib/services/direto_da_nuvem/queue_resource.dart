import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class QueueResource {
  static const collection = "queues";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Queue> _hiveBox = Hive.box<Queue>(collection);

  Future<List<Queue>> getAll() async {
    List<Queue> queues = [];

    try {
      if (await hasInternetConnection()) {
        final list = await _firestore.collection(collection).get();

        for (var doc in list.docs) {
          Queue queue = Queue.fromMap(doc.id, doc.data());
          queues.add(queue);
          _saveToLocalDB(queue);
        }
      } else {
        queues = _getAllFromLocalDB();
      }

      return queues;
    } catch (e) {
      debugPrint("Error on get all queues: $e");
      return [];
    }
  }

  Stream<List<Queue>> getAllStream() {
    var l = _firestore.collection(collection).snapshots();
    return l.map((event) {
      try {
        List<Queue> queues = [];

        for (var doc in event.docs) {
          Queue queue = Queue.fromMap(doc.id, doc.data());
          queues.add(queue);
          _saveToLocalDB(queue);
        }
        return queues;
      } catch (e) {
        debugPrint("Error on get all queues stream: $e");
        return [];
      }
    });
  }

  Future<Queue?> get(String id) async {
    try {
      if (await hasInternetConnection()) {
        var doc = await _firestore.doc("$collection/$id").get();
        if (!doc.exists) {
          return null;
        }
        final queue = Queue.fromMap(doc.id, doc.data()!);
        _saveToLocalDB(queue);
        return queue;
      } else {
        return _getFromLocalDB(id);
      }
    } catch (e) {
      debugPrint("Error on get queue $id: $e.");
      return null;
    }
  }

  Future<Queue?> getDefaultQueue() async {
    try {
      if (await hasInternetConnection()) {
        var doc = await _firestore.doc("$collection/init").get();
        if (!doc.exists) {
          return null;
        }
        final queue = Queue.fromMap(doc.id, doc.data()!);
        _saveToLocalDB(queue);
        return queue;
      } else {
        return _getFromLocalDB("init");
      }
    } catch (e) {
      debugPrint("Error on get default queue: $e");
      return null;
    }
  }

  delete(String id) async {
    try {
      await _firestore.doc("$collection/$id").delete();
      _deleteFromLocalDB(id);
    } catch (e) {
      debugPrint("Error on delete queue: $e");
    }
  }

  Stream<Queue?> getStream(String id) {
    var doc = _firestore.doc("$collection/$id").snapshots();
    return doc.map((event) {
      try {
        Queue queue = Queue.fromMap(event.id, event.data()!);
        _saveToLocalDB(queue);
        return queue;
      } catch (e) {
        debugPrint("Error on get queue stream $id: $e.");
        return null;
      }
    });
  }

  create(Queue queue) async {
    try {
      var doc = await _firestore.collection(collection).add(queue.toMap());
      queue.id = doc.id;
      _saveToLocalDB(queue);
    } catch (e) {
      debugPrint("Error on create queue: $e");
    }
  }

  update(Queue queue) async {
    try {
      var doc = _firestore.collection(collection).doc(queue.id);
      await doc.update(queue.toMap());
      _saveToLocalDB(queue);
    } catch (e) {
      debugPrint("Error on update queue: $e");
    }
  }

  // Hive
  _saveToLocalDB(Queue queue) {
    try {
      _hiveBox.put(queue.id, queue);
    } catch (e) {
      debugPrint("Error on save queue ${queue.id} to Hive: $e.");
    }
  }

  _deleteFromLocalDB(String id) {
    try {
      _hiveBox.delete(id);
    } catch (e) {
      debugPrint("Error on delete queue $id from Hive: $e.");
    }
  }

  Queue? _getFromLocalDB(String id) {
    try {
      return _hiveBox.values.firstWhere((q) => q.id == id);
    } catch (e) {
      debugPrint("Error on get queue $id from Hive: $e.");
      return null;
    }
  }

  List<Queue> _getAllFromLocalDB() {
    try {
      return _hiveBox.values.toList();
    } catch (e) {
      debugPrint("Error on list all queues from Hive: $e.");
      return [];
    }
  }
}
