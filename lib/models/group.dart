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
        createdAt: data["created_at"],
        updatedAt: data["updated_at"],
        admins: data["admins"]);
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
