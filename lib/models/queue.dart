import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/image_ui.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:hive/hive.dart';

part 'queue.g.dart';

@HiveType(typeId: 3)
class Queue extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String groupId;
  @HiveField(2)
  String name;
  @HiveField(3)
  int duration;
  @HiveField(4)
  String animation;
  @HiveField(5)
  DateTime createdAt;
  @HiveField(6)
  String createdBy;
  @HiveField(7)
  List<ImageUI> images;
  @HiveField(8)
  bool updated = true;
  @HiveField(9)
  String updatedBy;
  @HiveField(10)
  DateTime updatedAt;
  @HiveField(11)
  QueueStatus status;

  Queue({
    required this.id,
    required this.name,
    required this.groupId,
    required this.duration,
    required this.animation,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.images,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory Queue.fromMap(String id, Map<String, dynamic> data) {
    return Queue(
      id: id,
      name: data["name"],
      groupId: data["group_id"],
      duration: data["duration"],
      animation: data["animation"],
      status: queueStatusFromMap(data["status"]),
      createdAt: (data["created_at"] as Timestamp).toDate(),
      createdBy: data["created_by"],
      updatedBy: data["updated_by"] ?? "",
      updatedAt: (data["updated_at"] as Timestamp).toDate(),
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
      status: other.status,
      createdAt: other.createdAt,
      createdBy: other.createdBy,
      updatedBy: other.updatedBy,
      updatedAt: other.updatedAt,
      images: [...other.images]);
  }

  factory Queue.empty() {
    return Queue(
      id: "",
      name: "",
      groupId: "",
      status: QueueStatus.pending,
      duration: 0,
      animation: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      updatedBy: "",
      createdBy: "",
      images: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "images": images.map((e) => e.path).toList(),
      "name": name,
      "created_by": createdBy,
      "created_at": createdAt,
      "updated_by": updatedBy,
      "updated_at": updatedAt,
      "status": queueStatusToMap(status),
      "animation": animation,
      "duration": duration,
      "group_id": groupId,
    };
  }
}
