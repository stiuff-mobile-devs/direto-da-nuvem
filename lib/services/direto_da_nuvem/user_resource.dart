import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user.dart';

class UserResource {
  static String collection = "users";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> create(User user) async {
    DocumentReference docReference =
        _firestore.doc("$collection/${user.id}");

    DocumentSnapshot documentSnapshot = await docReference.get();
    if (documentSnapshot.exists) {
      return false;
    }
    docReference.set(user.toMap());
    return true;
  }

  Future<UserPrivileges> getUserPrivileges(String uid) async {
    var doc = await _firestore
        .doc('$collection/$uid/privileges/privileges').get();

    if (!doc.exists) {
      return UserPrivileges(
          isAdmin: false,
          isSuperAdmin: false,
          isInstaller: false
      );
    }

    return UserPrivileges.fromMap(doc.data()!);
  }

  Future<bool> userIsValid(String email) async {
    var query = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .get();

    if (!query.docs.isNotEmpty) {
      return false;
    }

    return true;
  }

// Future<bool> delegatePrivilege(String userId, UserPrivileges privileges) async {
//   return false;
// }
}
