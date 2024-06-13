import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user.dart';

class UserResource {
  static String collection = "users";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> create(User user) async {
    DocumentReference documentReference =
        _firestore.doc("${UserResource.collection}/${user.id}");
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      return false;
    }
    documentReference.set(user.toMap());
    return true;
  }

  Future<bool> delegatePrivilege(
      String userId, UserPrivileges privileges) async {
    return false;
  }

  Future<UserPrivilege> getUserPrivileges(String uid) async {
    var doc = await _firestore
        .doc('${UserResource.collection}/$uid/privileges/privileges')
        .get();

    if (!doc.exists) {
      return UserPrivilege(
          isAdmin: false, isSuperAdmin: false, isInstaller: false);
    }

    UserPrivilege privileges = UserPrivilege.fromMap(doc.data()!);
    return privileges;
  }
}
