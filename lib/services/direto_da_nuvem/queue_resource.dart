import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class QueueResource {
  static const collection = "queues";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Queue> _hiveBox = Hive.box<Queue>(collection);

  Future<List<Queue>> getAll() async {
    List<Queue> queues = [];

    try {
      if (await ConnectionService.isConnected()) {
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
    return _firestore.collection(collection).snapshots().map((e) {
      try {
        for (var change in e.docChanges) {
          switch (change.type) {
            case (DocumentChangeType.added || DocumentChangeType.modified) :
              final queue = Queue.fromMap(change.doc.id, change.doc.data()!);
              _saveToLocalDB(queue);
              break;
            case DocumentChangeType.removed:
              _deleteFromLocalDB(change.doc.id);
              break;
          }
        }

        return e.docs.map((doc) => Queue.fromMap(doc.id, doc.data())).toList();
      } catch (e) {
        debugPrint("Error on list all queues stream: $e");
        return [];
      }
    });
  }

  Future<Queue?> get(String id) async {
    try {
      if (await ConnectionService.isConnected()) {
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
      if (await ConnectionService.isConnected()) {
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
      throw Exception("Erro ao criar fila.");
    }
  }

  update(Queue queue) async {
    try {
      var doc = _firestore.collection(collection).doc(queue.id);
      await doc.update(queue.toMap());
      _saveToLocalDB(queue);
    } catch (e) {
      debugPrint("Error on update queue: $e");
      throw Exception("Erro ao atualizar fila.");
    }
  }

  delete(String id) async {
    try {
      await _firestore.doc("$collection/$id").delete();
      _deleteFromLocalDB(id);
    } catch (e) {
      debugPrint("Error on delete queue: $e");
      throw Exception("Erro ao excluir fila.");
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
