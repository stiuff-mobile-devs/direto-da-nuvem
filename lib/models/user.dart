import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

enum UserPrivileges {
  superAdmin,
  admin,
  installer;

  String get name {
    switch (this) {
      case UserPrivileges.admin:
        return "admin";
      case UserPrivileges.installer:
        return "installer";
      case UserPrivileges.superAdmin:
        return "super_admin";
      default:
        throw Exception("Privilégio inexistente");
    }
  }
}

class UserPrivilege {
  bool isAdmin;
  bool isSuperAdmin;
  bool isInstaller;

  UserPrivilege({
    required this.isAdmin,
    required this.isSuperAdmin,
    required this.isInstaller,
  });

  factory UserPrivilege.fromMap(Map<String, dynamic> map) {
    return UserPrivilege(
      isAdmin: map['admin'] ?? false,
      isSuperAdmin: map['super_admin'] ?? false,
      isInstaller: map['installer'] ?? false
    );
  }
}

class User {
  String id;
  String email;
  String name;
  DateTime createdAt;
  List<UserPrivileges> privileges;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.privileges,
  });

  factory User.fromFirebaseUser(firebase_auth.User firebaseAuthUser) {
    return User(
      id: firebaseAuthUser.uid,
      email: firebaseAuthUser.email!,
      name: firebaseAuthUser.displayName!,
      createdAt: DateTime.now(),
      privileges: []);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "created_at": createdAt,
    };
  }
}
