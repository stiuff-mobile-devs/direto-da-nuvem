import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';

class GroupResource {
  static const collection = "groups";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Group> _box = Hive.box<Group>(collection);

  Future<List<Group>> listAll() async {
    List<Group> groups = [];
    List<Future> futures = [];

    if (!await hasInternetConnection()) {
      groups = _box.values.toList();
    } else {
      var l = await _firestore.collection(GroupResource.collection).get();

      for (var doc in l.docs) {
        Group group = Group.fromMap(doc.data());
        group.id = doc.id;
        groups.add(group);
        Future f = _firestore
            .collection(collection)
            .doc(doc.id)
            .collection("admins")
            .doc("admins")
            .get()
            .then((value) {
          List<dynamic> adminsEmail = (value.data()!["admins"]);
          group.admins = adminsEmail.map((e) => "$e").toList();
        });
        futures.add(f);
      }
      await Future.wait(futures);

      for (var g in groups) {
        if (!_box.containsKey(g.id)) {
          _box.put(g.id, g);
        }
      }
    }

    return groups;
  }

  Future<Group?> get(String id) async {
    Group? group = _box.get(id);

    if (group == null && await hasInternetConnection()) {
      var doc = await _firestore.doc("$collection/$id").get();
      if (!doc.exists) {
        return null;
      }
      group = Group.fromMap(doc.data()!);
      await _firestore
          .collection(collection)
          .doc(doc.id)
          .collection("admins")
          .doc("admins")
          .get()
          .then((value) {
        List<dynamic> adminsEmail = (value.data()!["admins"]);
        group!.admins = adminsEmail.map((e) => "$e").toList();
      });
      _box.put(group.id, group);
    }

    return group;
  }

  Future create(Group group) async {
    var doc = await _firestore.collection(collection).add(group.toMap());
    group.id = doc.id;
    await _firestore
        .collection(collection)
        .doc(doc.id)
        .collection("admins")
        .doc("admins")
        .set({
      "admins": group.admins,
    });
  }

  Future update(Group group) async {
    var doc = _firestore.collection(collection).doc(group.id);
    var a = _firestore
        .collection(collection)
        .doc(doc.id)
        .collection("admins")
        .doc("admins")
        .set({
      "admins": group.admins,
    });
    var b = doc.update(group.toMap());
    await Future.wait([a, b]);
  }
}
