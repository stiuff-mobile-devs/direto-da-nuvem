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

  Future update(Device device) async {
    var doc = await _firestore
        .doc("$collection/${device.id}").get();

    if (!doc.exists) {
      return;
    }

    await _firestore.doc("$collection/${device.id}").update(device.toMap());
  }

  Future<Device?> get(String id) async {
    Device? device;

    if (await hasInternetConnection()) {
      final doc = await _firestore.doc("$collection/$id").get();

      if (!doc.exists) {
        return null;
      }

      device = Device.fromMap(doc.id, doc.data()!);
      _hiveBox.put(device.id, device);
    } else {
      device = _hiveBox.get(id);
    }

    return device;
  }

  Future<Device?> checkIfRegistered(String id) async {
    return await get(id);
  }

  Future<List<Device>> listAll() async {
    List<Device> devices = [];

    if (await hasInternetConnection()) {
      final docs = await _firestore.collection(collection).get();
      devices = docs.docs.map((e) => Device.fromMap(e.id, e.data())).toList();

      for (var device in devices) {
        _hiveBox.put(device.id, device);
      }
    } else {
      devices = _hiveBox.values.toList();
    }

    return devices;
  }

  Stream<List<Device>> listAllStream() {
    var l = _firestore.collection(collection).snapshots();
    return l.map((event) {
      List<Device> devices = [];

      for (var doc in event.docs) {
        Device device = Device.fromMap(doc.id, doc.data());
        devices.add(device);
        _hiveBox.put(device.id, device);
      }
      return devices;
    });
  }
}
