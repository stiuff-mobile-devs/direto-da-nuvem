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

  Map<String, dynamic> toMap() {
    return {
      "installer": isInstaller,
      "admin": isAdmin,
      "super_admin": isSuperAdmin,
    };
  }
}

class User {
  String id;
  String? uid;
  String email;
  String? name;
  UserPrivileges privileges;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  String updatedBy;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.privileges,
    this.name,
    this.uid
  });

  factory User.empty() {
    return User(
      id: "",
      name: "",
      uid: "",
      email: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: "",
      updatedBy: "",
      privileges: UserPrivileges(
        isAdmin: false,
        isSuperAdmin: false,
        isInstaller: false
      )
    );
  }

  factory User.fromMap(Map<String, dynamic> map, String id, UserPrivileges privileges) {
    return User(
      id: id,
      uid: map['uid'] ?? "",
      email: map['email'],
      name: map['name'] ?? "",
      createdAt: (map["created_at"] as Timestamp).toDate(),
      updatedAt: (map["updated_at"] as Timestamp).toDate(),
      createdBy: map["created_by"] ?? "",
      updatedBy: map["updated_by"] ?? "",
      privileges: privileges
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid ?? "",
      "email": email,
      "name": name ?? "",
      "created_at": createdAt,
      "updated_at": updatedAt,
      "created_by": createdBy,
      "updated_by": updatedBy,
    };
  }
}
