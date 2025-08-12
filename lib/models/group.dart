import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'group.g.dart';

@HiveType(typeId: 1)
class Group extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
  @HiveField(3)
  String currentQueue;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  DateTime updatedAt;
  @HiveField(6)
  List<String> admins;
  @HiveField(7)
  String createdBy;
  @HiveField(8)
  String updatedBy;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.currentQueue,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.admins,
  });

  factory Group.fromMap(String id, List<String> admins, Map<String, dynamic> data) {
    return Group(
      id: id,
      name: data["name"],
      description: data["description"],
      currentQueue: data["current_queue"],
      admins: admins,
      createdAt: (data["created_at"] as Timestamp).toDate(),
      updatedAt: (data["updated_at"] as Timestamp).toDate(),
      createdBy: data["created_by"] ?? "",
      updatedBy: data["updated_by"] ?? "",
    );
  }

  factory Group.empty() {
    return Group(
      id: "",
      name: "",
      description: "",
      currentQueue: "init",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: "",
      updatedBy: "",
      admins: [],
    );
  }

  factory Group.copy(Group group) {
    return Group(
      id: group.id,
      name: group.name,
      description: group.description,
      currentQueue: group.currentQueue,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
      createdBy: group.createdBy,
      updatedBy: group.updatedBy,
      admins: [...group.admins ?? []],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "current_queue": currentQueue,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "created_by": createdBy,
      "updated_by": updatedBy,
    };
  }
}
