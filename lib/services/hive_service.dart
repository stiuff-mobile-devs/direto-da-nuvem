import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/image_ui.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/models/user_privileges.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(DeviceAdapter());
    Hive.registerAdapter(GroupAdapter());
    Hive.registerAdapter(ImageUIAdapter());
    Hive.registerAdapter(QueueAdapter());
    Hive.registerAdapter(UserPrivilegesAdapter());
    Hive.registerAdapter(UserAdapter());

    // Tabelas
    await Hive.openBox<Device>('devices');
    await Hive.openBox<Group>('groups');
    await Hive.openBox<Queue>('queues');
    await Hive.openBox<ImageUI>('images');
    await Hive.openBox<User>('users');
  }
}