import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/image_ui.dart';

class Queue {
  String id;
  String groupId;
  String name;
  int duration;
  String animation;
  DateTime createdAt;
  String createdBy;
  List<ImageUI> images;
  bool updated = true;
  // List<Uint8List>? imagesData;

  Queue({
    required this.id,
    required this.name,
    required this.groupId,
    required this.duration,
    required this.animation,
    required this.createdAt,
    required this.createdBy,
    required this.images,
  });

  factory Queue.fromMap(Map<String, dynamic> data) {
    return Queue(
        id: data["id"],
        name: data["name"],
        groupId: data["group_id"],
        duration: data["duration"],
        animation: data["animation"],
        createdAt: (data["created_at"] as Timestamp).toDate(),
        createdBy: data["created_by"],
        images: (data["images"] as List)
            .map((e) => ImageUI(path: "$e", data: null))
            .toList());
  }

  factory Queue.copy(Queue other) {
    return Queue(
        id: other.id,
        name: other.name,
        groupId: other.groupId,
        duration: other.duration,
        animation: other.animation,
        createdAt: other.createdAt,
        createdBy: other.createdBy,
        images: [...other.images]);
  }

  Map<String, dynamic> toMap() {
    return {
      "images": images.map((e) => e.path).toList(),
      "name": name,
      "created_by": createdBy,
      "created_at": createdAt,
      "animation": animation,
      "duration": duration,
      "group_id": groupId,
      "id": id,
    };
  }
}
