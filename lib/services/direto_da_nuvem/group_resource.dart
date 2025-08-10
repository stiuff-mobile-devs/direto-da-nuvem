import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';

class GroupResource {
  static const collection = "groups";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Group> _hiveBox = Hive.box<Group>(collection);

  Future<List<Group>> listAll() async {
    List<Group> groups = [];

    if (await hasInternetConnection()) {
      final list = await _firestore.collection(collection).get();

      for (var doc in list.docs) {
        List<String> adminsList = await _getGroupAdmins(doc.id);
        Group group = Group.fromMap(doc.id, adminsList, doc.data());
        groups.add(group);
        _hiveBox.put(group.id, group);
      }
    } else {
      groups = _hiveBox.values.toList();
    }

    return groups;
  }

  Future<Group?> get(String id) async {
    Group? group;

    if (await hasInternetConnection()) {
      var doc = await _firestore.doc("$collection/$id").get();

      if (!doc.exists) {
        return null;
      }

      List<String> adminsList = await _getGroupAdmins(doc.id);
      group = Group.fromMap(doc.id, adminsList, doc.data()!);
      _hiveBox.put(group.id, group);
    } else {
      group = _hiveBox.get(id);
    }

    return group;
  }

  Future<List<String>> _getGroupAdmins(String groupId) async {
    var adminsDoc = await _firestore
        .doc("$collection/$groupId/admins/admins").get();

    var admins = (adminsDoc.data()!["admins"]).map((e) => "$e").toList();
    return List<String>.from(admins);
  }

  Future<void> create(Group group) async {
    var doc = await _firestore.collection(collection).add(group.toMap());
    await _firestore.doc("$collection/${doc.id}/admins/admins")
        .set({"admins": group.admins});

    group.id = doc.id;
    _hiveBox.put(group.id, group);
  }

  Future<bool> update(Group group) async {
    final docReference = _firestore.doc("$collection/${group.id}");
    final docSnapshot = await docReference.get();

    if (!docSnapshot.exists) {
      return false;
    }

    var a = docReference.update(group.toMap());
    var b = _firestore.doc("$collection/${group.id}/admins/admins")
        .update({"admins": group.admins});

    await Future.wait([a, b]);
    _hiveBox.put(group.id, group);
    return true;
  }
}
