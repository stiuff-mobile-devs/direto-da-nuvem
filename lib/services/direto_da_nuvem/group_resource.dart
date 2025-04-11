import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/group.dart';

class GroupResource {
  static const collection = "groups";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Group>> listAll() async {
    var l = await _firestore.collection(GroupResource.collection).get();

    List<Group> groups = [];
    List<Future> futures = [];

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
    return groups;
  }

  Future<Group?> get(String id) async {
    var doc = await _firestore.doc("$collection/$id").get();
    if (!doc.exists) {
      return null;
    }
    Group group = Group.fromMap(doc.data()!);
    await _firestore
        .collection(collection)
        .doc(doc.id)
        .collection("admins")
        .doc("admins")
        .get()
        .then((value) {
      List<dynamic> adminsEmail = (value.data()!["admins"]);
        group.admins = adminsEmail.map((e) => "$e").toList();
    });
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
    await doc.update(group.toMap());
  }
}
