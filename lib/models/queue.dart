import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Queue {
  String id;
  String groupId;
  int duration;
  String animation;
  DateTime createdAt;
  String createdBy;
  List<String> images;
  List<Uint8List>? imagesData;

  Queue({
    required this.id,
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
        groupId: data["group_id"],
        duration: data["duration"],
        animation: data["animation"],
        createdAt: (data["created_at"] as Timestamp).toDate(),
        createdBy: data["created_by"],
        images: (data["images"] as List).map((e) => "$e").toList());
  }
}
