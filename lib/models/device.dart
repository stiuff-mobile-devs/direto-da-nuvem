import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  String id;
  String locale;
  String description;
  String groupId;
  String registeredBy;
  DateTime createdAt;
  DateTime updatedAt;

  Device({
    required this.id,
    required this.locale,
    required this.description,
    required this.groupId,
    required this.registeredBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
        id: map["id"],
        locale: map["locale"],
        description: map["description"],
        groupId: map["group_id"],
        registeredBy: map["registered_by"],
        createdAt: (map["created_at"] as Timestamp).toDate(),
        updatedAt: (map["updated_at"] as Timestamp).toDate());
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "locale": locale,
      "description": description,
      "group_id": groupId,
      "registered_by": registeredBy,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
}
