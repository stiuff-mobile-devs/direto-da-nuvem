import 'package:ddnuvem/models/image.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 3)
class ExternalQueue extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int duration;
  @HiveField(3)
  String animation;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  List<Image> images;
  @HiveField(6)
  bool updated = true;

  ExternalQueue({
    required this.id,
    required this.name,
    required this.duration,
    required this.animation,
    required this.createdAt,
    required this.images,
  });

  factory ExternalQueue.fromMap(Map<String, dynamic> data) {
    return ExternalQueue(
      id: data["id"],
      name: data["name"],
      duration: data["duration"],
      animation: data["animation"] ?? "Padrão",
      createdAt: DateTime.parse(data["created_at"]),
      images: (data["images"] as List? ?? [])
          .map((e) => Image(path: e.toString(), data: null))
          .toList(),
    );
  }

  factory ExternalQueue.copy(ExternalQueue other) {
    return ExternalQueue(
        id: const Uuid().v1(),
        name: other.name,
        duration: other.duration,
        animation: other.animation,
        createdAt: other.createdAt,
        images: [...other.images]);
  }

  factory ExternalQueue.fromQueue(Queue queue) {
    return ExternalQueue(
        id: queue.id == "" ? const Uuid().v1() : queue.id,
        name: queue.name,
        duration: queue.duration,
        animation: queue.animation,
        createdAt: queue.createdAt,
        images: [...queue.images]);
  }

  factory ExternalQueue.empty() {
    return ExternalQueue(
      id: const Uuid().v1(),
      name: "",
      duration: 10,
      animation: "Padrão",
      createdAt: DateTime.now(),
      images: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "images": images.map((e) => e.path).toList(),
      "name": name,
      "created_at": createdAt.toIso8601String(),
      "animation": animation,
      "duration": duration,
    };
  }
}
