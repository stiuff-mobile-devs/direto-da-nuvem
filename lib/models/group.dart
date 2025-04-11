import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String? id;
  String name;
  String description;
  String currentQueue;
  DateTime createdAt;
  DateTime updatedAt;
  List<String>? admins;

  Group(
      {this.id,
      required this.name,
      required this.description,
      required this.currentQueue,
      required this.createdAt,
      required this.updatedAt,
      required this.admins});

  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
        id: data["id"],
        name: data["name"],
        description: data["description"],
        currentQueue: data["current_queue"],
        createdAt: (data["created_at"] as Timestamp).toDate(),
        updatedAt: (data["updated_at"] as Timestamp).toDate(),
        admins: data["admins"]);
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
