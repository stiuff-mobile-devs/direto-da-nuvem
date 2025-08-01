import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';

class DeviceResource {
  static const String collection = "devices";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Device> _box = Hive.box<Device>(collection);

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
    Device? device = _box.get(id);

    if (device == null && await hasInternetConnection()) {
      final documentSnapshot =
      await _firestore.doc("${DeviceResource.collection}/$id").get();

      if (!documentSnapshot.exists) {
        return null;
      }
      device = Device.fromMap(documentSnapshot.data()!);
      _box.put(device.id, device);
    }

    return device;
  }


  Future<List<Device>> listAll() async {
    List<Device> devices = [];

    if (await hasInternetConnection()) {
      final documents =
      await _firestore.collection(DeviceResource.collection).get();
      devices = documents.docs.map((e) => Device.fromMap(e.data())).toList();
      _saveRemoteDevicesToLocal(devices);
    } else {
      devices = _box.values.toList();
    }

    return devices;
  }

  Future<void> _saveRemoteDevicesToLocal(List<Device> devices) async {
    for (var device in devices) {
      if (!_box.containsKey(device.id)) {
        _box.put(device.id, device);
      }
    }
  }

  List<Device> listInGroup(String groupId) {
    return [];
  }
}
