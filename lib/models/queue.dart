class Queue {
  String id;
  String groupId;
  double duration;
  String animation;
  DateTime createdAt;
  String createdBy;
  List<String> images;

  Queue({
    required this.id,
    required this.groupId,
    required this.duration,
    required this.animation,
    required this.createdAt,
    required this.createdBy,
    required this.images,
  });
}
