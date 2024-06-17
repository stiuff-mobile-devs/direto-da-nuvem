import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/device.dart';

class DeviceResource {
  static const String collection = "devices";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> create(Device device) async {
    DocumentReference documentReference =
        _firestore.doc("${DeviceResource.collection}/${device.id}");
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      return false;
    }
    documentReference.set(device.toMap());
    return true;
  }

  Future<bool> checkIfRegistered(String id) async {
    DocumentReference documentReference =
        _firestore.doc("${DeviceResource.collection}/$id");
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot.exists;
  }

  Future<Device?> get(String id) async {
    final documentSnapshot =
        await _firestore.doc("${DeviceResource.collection}/$id").get();
    
    if (!documentSnapshot.exists) {
      return null;
    }
    return Device.fromMap(documentSnapshot.data()!);
  }

  List<Device> listAll() {
    return [];
  }

  List<Device> listInGroup(String groupId) {
    return [];
  }
}
