class Device {
  String id;
  String locale;
  String description;
  String groupId;
  DateTime createdAt;
  DateTime updatedAt;

  Device({
    required this.id,
    required this.locale,
    required this.description,
    required this.groupId,
    required this.createdAt,
    required this.updatedAt,
  });
}
