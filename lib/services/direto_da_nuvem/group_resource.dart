import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/group.dart';

class GroupResource {
  static const collection = "groups";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Group>> listAll() async {
    var l = await _firestore.collection(GroupResource.collection).get();

    List<Group> groups = [];

    for (var doc in l.docs) {
      Group group = Group.fromMap(doc.data());
      group.id = doc.id;
      groups.add(group);
    }
    return groups;
  }

  Future<Group?> get(String id) async {
    var doc = await _firestore.doc("$collection/$id").get();
    if (!doc.exists) {
      return null;
    }
    return Group.fromMap(doc.data()!);
  }

  Future create(Group group) async {
    var doc = await _firestore.collection(collection).add(group.toMap());
    await _firestore.collection(collection).doc(doc.id).collection("admins").doc("admins").set({
      "admins": group.admins,
    });
  }
}
