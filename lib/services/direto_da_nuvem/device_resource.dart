import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/utils/connection_utils.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class DeviceResource {
  static const String collection = "devices";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Device> _hiveBox = Hive.box<Device>(collection);

  Future<bool> create(Device device) async {
    try {
      if (await get(device.id) != null) {
        throw Exception("Dispositivo já existe.");
      }

      await _firestore.doc("$collection/${device.id}").set(device.toMap());
      _saveToLocalDB(device);
      return true;
    } catch (e) {
      debugPrint("Error on create device: $e");
      return false;
    }
  }

  update(Device device) async {
    try {
      var doc = await _firestore.doc("$collection/${device.id}").get();

      if (!doc.exists) {
        return;
      }

      await _firestore.doc("$collection/${device.id}").update(device.toMap());
    } catch (e) {
      debugPrint("Error on update device: $e");
    }
  }

  Future<Device?> get(String id) async {
    Device? device;

    try {
      if (await hasInternetConnection()) {
        final doc = await _firestore.doc("$collection/$id").get();

        if (!doc.exists) {
          return null;
        }

        device = Device.fromMap(doc.id, doc.data()!);
        _saveToLocalDB(device);
      } else {
        device = _getFromLocalDB(id);
      }
      return device;
    } catch (e) {
      debugPrint("Error on get device: $e");
      return null;
    }
  }

  Future<List<Device>> getAll() async {
    List<Device> devices = [];

    try {
      if (await hasInternetConnection()) {
        final docs = await _firestore.collection(collection).get();
        devices = docs.docs.map((e) => Device.fromMap(e.id, e.data())).toList();

        for (var device in devices) {
          _saveToLocalDB(device);
        }
      } else {
        devices = _getAllFromLocalDB();
      }
      return devices;
    } catch (e) {
      debugPrint("Error on list all devices: $e");
      return [];
    }
  }

  Stream<List<Device>> getAllStream() {
    var l = _firestore.collection(collection).snapshots();

    return l.map((event) {
      try {
        List<Device> devices = [];

        for (var doc in event.docs) {
          Device device = Device.fromMap(doc.id, doc.data());
          devices.add(device);
          _saveToLocalDB(device);
        }
        return devices;
      } catch (e) {
        debugPrint("Error on list all devices stream: $e");
        return [];
      }
    });
  }

  // Hive
  _saveToLocalDB(Device device) {
    try {
      _hiveBox.put(device.id, device);
    } catch (e) {
      debugPrint("Error on save device ${device.id} to Hive: $e.");
    }
  }

  Device? _getFromLocalDB(String id) {
    try {
      return _hiveBox.get(id);
    } catch (e) {
      debugPrint("Error on get device $id from Hive: $e.");
      return null;
    }
  }

  List<Device> _getAllFromLocalDB() {
    try {
      return _hiveBox.values.toList();
    } catch (e) {
      debugPrint("Error on list all devices from Hive: $e.");
      return [];
    }
  }
}
