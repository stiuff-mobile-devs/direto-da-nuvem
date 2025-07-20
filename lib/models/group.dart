import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'group.g.dart';

@HiveType(typeId: 1)
class Group extends HiveObject {
  @HiveField(0)
  String? id;
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
  List<String>? admins;

  Group({
    this.id,
    required this.name,
    required this.description,
    required this.currentQueue,
    required this.createdAt,
    required this.updatedAt,
    required this.admins
  });

  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
      id: data["id"],
      name: data["name"],
      description: data["description"],
      currentQueue: data["current_queue"],
      createdAt: (data["created_at"] as Timestamp).toDate(),
      updatedAt: (data["updated_at"] as Timestamp).toDate(),
      admins: data["admins"]
    );
  }

  factory Group.empty() {
    return Group(
      name: "",
      description: "",
      currentQueue: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
    };
  }
}
