import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user.dart';

class UserResource {
  static String collection = "users";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> create(User user) async {
    if (await userIsValid(user.email) != null) {
      return "Usuário já cadastrado!";
    }

    var doc = await _firestore.collection(collection).add(user.toMap());
    await _firestore.doc("$collection/${doc.id}/privileges/privileges")
        .set(user.privileges.toMap());
    return "Usuário criado com sucesso!";
  }

  Future<User?> get(String uid) async {
    final query = await _firestore
        .collection(collection)
        .where('uid', isEqualTo: uid)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    UserPrivileges privileges = await _getUserPrivileges(doc.id);
    return User.fromMap(doc.data(), doc.id, privileges);
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

    if (!doc.exists) {
      return UserPrivileges(
          isAdmin: false,
          isSuperAdmin: false,
          isInstaller: false
      );
    }

    return UserPrivileges.fromMap(doc.data()!);
  }

  Future<Map<String,String>?> userIsValid(String email) async {
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
