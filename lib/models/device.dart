import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'device.g.dart';

@HiveType(typeId: 0)
class Device extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String locale;
  @HiveField(3)
  String description;
  @HiveField(4)
  String groupId;
  @HiveField(5)
  String registeredBy;
  @HiveField(6)
  String registeredByEmail;
  @HiveField(7)
  String? brand;
  @HiveField(8)
  String? model;
  @HiveField(9)
  String? product;
  @HiveField(10)
  String? device;
  @HiveField(11)
  DateTime createdAt;
  @HiveField(12)
  DateTime updatedAt;

  Device({
    required this.id,
    required this.locale,
    required this.description,
    required this.groupId,
    required this.registeredBy,
    required this.registeredByEmail,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.model,
    this.product,
    this.device,
  });

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map["id"],
      locale: map["locale"],
      description: map["description"],
      groupId: map["group_id"],
      registeredBy: map["registered_by"] ?? "",
      registeredByEmail: map["registered_by_email"] ?? "",
      createdAt: (map["created_at"] as Timestamp).toDate(),
      updatedAt: (map["updated_at"] as Timestamp).toDate(),
      brand: map["brand"],
      model: map["model"],
      product: map["product"],
      device: map["device"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "locale": locale,
      "description": description,
      "group_id": groupId,
      "registered_by": registeredBy,
      "registered_by_email": registeredByEmail,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "brand": brand,
      "model": model,
      "product": product,
      "device": device,
    };
  }
}