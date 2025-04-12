class Image {
  String path;
  DateTime? createdAt;
  DateTime? updatedAt;

  Image({
    required this.path,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Image.fromMap(Map<String, dynamic> data) {
    return Image(
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      path: data['path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'path': path,
    };
  }
}
