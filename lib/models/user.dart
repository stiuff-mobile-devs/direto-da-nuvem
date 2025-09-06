import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user_privileges.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class User extends HiveObject {
  @HiveField(0)
  String id; // uid
  @HiveField(1)
  String email;
  @HiveField(2)
  String name;
  @HiveField(3)
  UserPrivileges privileges;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  DateTime updatedAt;
  @HiveField(6)
  String createdBy;
  @HiveField(7)
  String updatedBy;
  @HiveField(8)
  bool authenticated;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.privileges,
    required this.name,
    required this.authenticated
  });

  factory User.empty() {
    return User(
      id: "",
      name: "",
      email: "",
      authenticated: false,
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

  factory User.copy(User user) {
    return User(
      id: user.id,
      email: user.email,
      name: user.name,
      authenticated: user.authenticated,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      createdBy: user.createdBy,
      updatedBy: user.updatedBy,
      privileges: UserPrivileges(
        isAdmin: user.privileges.isAdmin,
        isSuperAdmin: user.privileges.isSuperAdmin,
        isInstaller: user.privileges.isInstaller
      )
    );
  }

  factory User.fromMap(Map<String, dynamic> map, String id, UserPrivileges privileges) {
    return User(
      id: id,
      email: map['email'],
      name: map['name'] ?? "",
      authenticated: map['authenticated'],
      createdAt: (map["created_at"] as Timestamp).toDate(),
      updatedAt: (map["updated_at"] as Timestamp).toDate(),
      createdBy: map["created_by"] ?? "",
      updatedBy: map["updated_by"] ?? "",
      privileges: privileges
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "authenticated": authenticated,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "created_by": createdBy,
      "updated_by": updatedBy,
    };
  }
}
