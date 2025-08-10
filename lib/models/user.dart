import 'package:cloud_firestore/cloud_firestore.dart';

class UserPrivileges {
  bool isAdmin;
  bool isSuperAdmin;
  bool isInstaller;

  UserPrivileges({
    required this.isAdmin,
    required this.isSuperAdmin,
    required this.isInstaller,
  });

  factory UserPrivileges.fromMap(Map<String, dynamic> map) {
    return UserPrivileges(
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
  UserPrivileges privileges;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.privileges,
  });

  factory User.fromMap(Map<String, dynamic> map, UserPrivileges privileges) {
    return User(
      id: map['uid'],
      email: map['email'],
      name: map['name'],
      createdAt: (map["created_at"] as Timestamp).toDate(),
      privileges: privileges
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": id,
      "email": email,
      "name": name,
      "created_at": createdAt,
    };
  }
}
