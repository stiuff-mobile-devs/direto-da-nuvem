import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/models/user_privileges.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';

class UserResource {
  static String collection = "users";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<User> _hiveBox = Hive.box<User>(collection);

  Future<List<User>> listAll() async {
    List<User> users = [];

    if (await hasInternetConnection()) {
      final list = await _firestore.collection(collection).get();

      for (var doc in list.docs) {
        UserPrivileges privileges = await _getUserPrivileges(doc.id);
        User user = User.fromMap(doc.data(), doc.id, privileges);
        users.add(user);
        _hiveBox.put(user.id, user);
      }
    } else {
      users = _hiveBox.values.toList();
    }

    return users;
  }

  Future<bool> create(User user) async {
    if (await checkAuthorizedLogin(user.email) != null) {
      return false;
    }

    var doc = await _firestore.collection(collection).add(user.toMap());
    await _firestore.doc("$collection/${doc.id}/privileges/privileges")
        .set(user.privileges.toMap());
    _hiveBox.put(user.id, user);
    return true;
  }

  Future<User?> get(String uid) async {
    User? user;

    if (await hasInternetConnection()) {
      final query = await _firestore
          .collection(collection)
          .where('uid', isEqualTo: uid)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      final doc = query.docs.first;
      UserPrivileges privileges = await _getUserPrivileges(doc.id);
      user = User.fromMap(doc.data(), doc.id, privileges);
      _hiveBox.put(user.id, user);
    } else {
      try {
        user = _hiveBox.values.firstWhere((u) => u.uid == uid);
      } catch (e) {
        return null;
      }
    }

    return user;
  }

  Future<void> update(User user) async {
    var doc = await _firestore
        .doc("$collection/${user.id}").get();

    if (!doc.exists) {
      return;
    }

    await _firestore.doc("$collection/${user.id}").update(user.toMap());
    await _firestore.doc("$collection/${user.id}/privileges/privileges")
        .update(user.privileges.toMap());
  }

  Future updateAuthenticatedUser(String id, String uid, String name) async {
    var doc = await _firestore.doc("$collection/$id").get();

    if (!doc.exists) {
      return;
    }

    await _firestore.doc("$collection/$id").update({
      "uid": uid,
      "name": name,
      "updated_at": DateTime.now(),
      "updated_by": uid,
    });
  }

  Future<UserPrivileges> _getUserPrivileges(String id) async {
    var doc = await _firestore
        .doc('$collection/$id/privileges/privileges').get();

    if (doc.exists) {
      return UserPrivileges.fromMap(doc.data()!);
    }

    return UserPrivileges(
        isAdmin: false,
        isSuperAdmin: false,
        isInstaller: false
    );
  }

  Future<Map<String,String>?> checkAuthorizedLogin(String email) async {
    var query = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    return {
      "id": doc.id,
      "uid": doc.data()['uid'] ?? ""
    };
  }

  Future<bool> userIsAdmin(String email) async {
    var query = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) {
      return false;
    }

    final doc = query.docs.first;
    UserPrivileges privileges = await _getUserPrivileges(doc.id);
    return privileges.isAdmin || privileges.isSuperAdmin;
  }
}
