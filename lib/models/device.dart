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

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
        id: map["id"],
        locale: map["locale"],
        description: map["description"],
        groupId: map["group_id"],
        createdAt: map["created_at"],
        updatedAt: map["updated_at"]);
  }

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
