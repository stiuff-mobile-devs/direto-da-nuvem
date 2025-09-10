import 'package:ddnuvem/app.dart';
import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/hive_service.dart';
import 'package:ddnuvem/services/local_storage_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/devices/devices_filter_controller.dart';
import 'package:ddnuvem/views/people/people_filter_controller.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  }
  await HiveService.initialize();

  runApp(MultiProvider(providers: [
    Provider<DiretoDaNuvemAPI>(create: (context) => DiretoDaNuvemAPI()),
    Provider<LocalStorageService>(create: (context) => LocalStorageService()),
    ChangeNotifierProvider<SignInService>(create: (context) => SignInService()),
    ChangeNotifierProvider<ConnectionService>(
        create: (context) => ConnectionService()),
    ChangeNotifierProvider<UserController>(
        create: (context) => UserController(context.read(), context.read())),
    ChangeNotifierProvider<DevicesFilterController>(
        create: (context) => DevicesFilterController()),
    ChangeNotifierProvider<QueueController>(
        create: (context) => QueueController(context.read(), context.read())),
    ChangeNotifierProvider<GroupController>(
        create: (context) => GroupController(context.read(), context.read())),
    ChangeNotifierProvider<DeviceController>(
        create: (context) => DeviceController(context.read(), context.read())),
    ChangeNotifierProvider<PeopleFilterController>(
        create: (context) => PeopleFilterController())
  ], child: const App()));
}
