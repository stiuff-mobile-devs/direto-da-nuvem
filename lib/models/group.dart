class Group {
  String id;
  String name;
  String description;
  String currentQueue;
  DateTime createdAt;
  DateTime updatedAt;
  List<String>? admins;

  Group(
      {required this.id,
      required this.name,
      required this.description,
      required this.currentQueue,
      required this.createdAt,
      required this.updatedAt,
      required this.admins});
}
