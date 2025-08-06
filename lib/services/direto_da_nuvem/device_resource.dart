import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';

class DeviceResource {
  static const String collection = "devices";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Device> _hiveBox = Hive.box<Device>(collection);

  Future<bool> create(Device device) async {
    if (await checkIfRegistered(device.id) != null) {
      return false;
    }

    await _firestore.doc("$collection/${device.id}").set(device.toMap());
    _hiveBox.put(device.id, device);
    return true;
  }

  Future<Device?> checkIfRegistered(String id) async {
    final docSnapshot = await _firestore.doc("$collection/$id").get();

    if (!docSnapshot.exists) {
      return null;
    }

    return Device.fromMap(docSnapshot.data()!);
  }

  Future<Device?> get(String id) async {
    Device? device = _hiveBox.get(id);

    if (device == null && await hasInternetConnection()) {
      final docSnapshot = await _firestore.doc("$collection/$id").get();

      if (!docSnapshot.exists) {
        return null;
      }

      device = Device.fromMap(docSnapshot.data()!);
      _hiveBox.put(device.id, device);
    }

    return device;
  }

  Future<List<Device>> listAll() async {
    List<Device> devices = [];

    if (await hasInternetConnection()) {
      final docs = await _firestore.collection(collection).get();
      devices = docs.docs.map((e) => Device.fromMap(e.data())).toList();

      for (var device in devices) {
        if (!_hiveBox.containsKey(device.id)) {
          _hiveBox.put(device.id, device);
        }
      }
    } else {
      devices = _hiveBox.values.toList();
    }

    return devices;
  }
}
