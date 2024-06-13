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

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "locale": locale,
      "description": description,
      "group_id": groupId,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
}
