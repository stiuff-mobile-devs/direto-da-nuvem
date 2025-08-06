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
      var list = await _firestore.collection(collection).get();

      for (var doc in list.docs) {
        Group group = Group.fromMap(doc.data());
        group.id = doc.id;
        groups.add(group);

        await _firestore.doc("$collection/${doc.id}/admins/admins")
            .get().then((value) {
          List<dynamic> adminsEmail = (value.data()!["admins"]);
          group.admins = adminsEmail.map((e) => "$e").toList();
        });

        if (!_hiveBox.containsKey(group.id)) {
          _hiveBox.put(group.id, group);
        }
      }
    } else {
      groups = _hiveBox.values.toList();
    }

    return groups;
  }

  Future<Group?> get(String id) async {
    Group? group = _hiveBox.get(id);

    if (group == null && await hasInternetConnection()) {
      var doc = await _firestore.doc("$collection/$id").get();

      if (!doc.exists) {
        return null;
      }

      group = Group.fromMap(doc.data()!);
      await _firestore.doc("$collection/$id/admins/admins")
          .get().then((value) {
            List<dynamic> adminsEmail = (value.data()!["admins"]);
            group!.admins = adminsEmail.map((e) => "$e").toList();
          });

      _hiveBox.put(group.id, group);
    }

    return group;
  }

  Future<void> create(Group group) async {
    var doc = await _firestore.collection(collection).add(group.toMap());
    await _firestore.doc("$collection/${doc.id}/admins")
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
