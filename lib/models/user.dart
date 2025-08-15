import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user_privileges.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class User extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String uid;
  @HiveField(2)
  String email;
  @HiveField(3)
  String name;
  @HiveField(4)
  UserPrivileges privileges;
  @HiveField(5)
  DateTime createdAt;
  @HiveField(6)
  DateTime updatedAt;
  @HiveField(7)
  String createdBy;
  @HiveField(8)
  String updatedBy;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.privileges,
    required this.name,
    required this.uid
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
    DateTime? createdAt;
    DateTime? updatedAt;

    if (map["created_at"] is Timestamp) {
      createdAt = (map["created_at"] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    if (map["updated_at"] is Timestamp) {
      updatedAt = (map["updated_at"] as Timestamp).toDate();
    } else {
      updatedAt = DateTime.now();
    }

    return User(
      id: id,
      uid: map['uid'] ?? "",
      email: map['email'],
      name: map['name'] ?? "",
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: map["created_by"] ?? "",
      updatedBy: map["updated_by"] ?? "",
      privileges: privileges
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "created_by": createdBy,
      "updated_by": updatedBy,
    };
  }
}
