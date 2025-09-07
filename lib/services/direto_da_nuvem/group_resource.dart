import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class GroupResource {
  static const collection = "groups";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Group> _hiveBox = Hive.box<Group>(collection);

  Future<List<Group>> getAll() async {
    List<Group> groups = [];

    try {
      if (await ConnectionService.isConnected()) {
        final list = await _firestore.collection(collection).get();

        for (var doc in list.docs) {
          Group group = Group.fromMap(doc.id, doc.data());
          groups.add(group);
          _saveToLocalDB(group);
        }
      } else {
        groups = _getAllFromLocalDB();
      }
      return groups;
    } catch (e) {
      debugPrint("Error on get all groups: $e");
      return [];
    }
  }

  Future<List<Group>> getAllToAdmin(String email) async {
    List<Group> groups = [];

    try {
      if (await ConnectionService.isConnected()) {
        final list = await _firestore.collection(collection)
            .where("admins", arrayContains: email).get();

        for (var doc in list.docs) {
          Group group = Group.fromMap(doc.id, doc.data());
          groups.add(group);
          _saveToLocalDB(group);
        }
      } else {
        groups = _getAllFromLocalDB();
      }
      return groups;
    } catch (e) {
      debugPrint("Error on get all groups to admin: $e");
      return [];
    }
  }

  Stream<List<Group>> getAllStream() {
    var l = _firestore.collection(collection).snapshots();
    return l.map((event) {
      try {
        List<Group> groups = [];

        for (var doc in event.docs) {
          Group group = Group.fromMap(doc.id, doc.data());
          groups.add(group);
          _saveToLocalDB(group);
        }
        return groups;
      } catch (e) {
        debugPrint("Error on get all groups stream: $e");
        return [];
      }
    });
  }

  Stream<List<Group>> getAllStreamToAdmin(String email) {
    var l = _firestore.collection(collection)
        .where("admins", arrayContains: email).snapshots();
    return l.map((event) {
      try {
        List<Group> groups = [];

        for (var doc in event.docs) {
          Group group = Group.fromMap(doc.id, doc.data());
          groups.add(group);
          _saveToLocalDB(group);
        }
        return groups;
      } catch (e) {
        debugPrint("Error on get all groups stream to admin: $e");
        return [];
      }
    });
  }

  Future<Group?> get(String id) async {
    Group? group;

    try {
      if (await ConnectionService.isConnected()) {
        var doc = await _firestore.doc("$collection/$id").get();

        if (!doc.exists) {
          return null;
        }

        group = Group.fromMap(doc.id, doc.data()!);
        _saveToLocalDB(group);
      } else {
        group = _getFromLocalDB(id);
      }

      return group;
    } catch (e) {
      debugPrint("Error on get group $id: $e.");
      return null;
    }
  }

  Stream<Group?> getStream(String id) {
    var doc = _firestore.doc("$collection/$id").snapshots();
    return doc.map((event) {
      try {
        Group group = Group.fromMap(event.id, event.data()!);
        _saveToLocalDB(group);
        return group;
      } catch (e) {
        debugPrint("Error on get group stream $id: $e.");
        return null;
      }
    });
  }

  create(Group group) async {
    try {
      await _firestore.collection(collection).add(group.toMap());
    } catch (e) {
      debugPrint("Error on create group ${group.id}: $e.");
    }
  }

  Future<bool> update(Group group) async {
    try {
      final docReference = _firestore.doc("$collection/${group.id}");
      final doc = await docReference.get();

      if (!doc.exists) {
        return false;
      }

      await docReference.update(group.toMap());
      return true;
    } catch (e) {
      debugPrint("Error on update group ${group.id}: $e.");
      return false;
    }
  }

  delete(String id) async {
    try {
      await _firestore.doc("$collection/$id").delete();
      _deleteFromLocalDB(id);
    } catch (e) {
      debugPrint("Error on delete group $id: $e.");
    }
  }

  // Hive
  _saveToLocalDB(Group group) {
    try {
      _hiveBox.put(group.id, group);
    } catch (e) {
      debugPrint("Error on save group ${group.id} to Hive: $e.");
    }
  }

  _deleteFromLocalDB(String id) {
    try {
      _hiveBox.delete(id);
    } catch (e) {
      debugPrint("Error on delete group $id from Hive: $e.");
    }
  }

  Group? _getFromLocalDB(String id) {
    try {
      return _hiveBox.values.firstWhere((g) => g.id == id);
    } catch (e) {
      debugPrint("Error on get group $id from Hive: $e.");
      return null;
    }
  }

  List<Group> _getAllFromLocalDB() {
    try {
      return _hiveBox.values.toList();
    } catch (e) {
      debugPrint("Error on list all groups from Hive: $e.");
      return [];
    }
  }
}
