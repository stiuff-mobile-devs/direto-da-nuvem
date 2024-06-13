class User {
  String id;
  String email;
  String name;
  DateTime createdAt;
  List<String> privileges;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.privileges,
  });
}