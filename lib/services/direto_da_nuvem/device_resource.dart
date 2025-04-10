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

  Future<Device?> checkIfRegistered(String id) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        _firestore.doc("${DeviceResource.collection}/$id");
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    if (!documentSnapshot.exists) {
      return null;
    }
    return Device.fromMap(documentSnapshot.data()!);
  }

  Future<Device?> get(String id) async {
    final documentSnapshot =
        await _firestore.doc("${DeviceResource.collection}/$id").get();

    if (!documentSnapshot.exists) {
      return null;
    }
    return Device.fromMap(documentSnapshot.data()!);
  }

  Future<List<Device>> listAll() async {
    final documents =
        await _firestore.collection(DeviceResource.collection).get();
    return documents.docs.map((e) => Device.fromMap(e.data())).toList();
  }

  List<Device> listInGroup(String groupId) {
    return [];
  }
}
