import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:ddnuvem/services/sign_in_service.dart';
import 'package:ddnuvem/views/dashboard_page.dart';
import 'package:ddnuvem/views/devices/register_device_page.dart';
import 'package:ddnuvem/views/devices/unregistered_device_error_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/login_page.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedirectionData {
  bool firstTime;
  bool loggedIn;
  bool isInstaller;
  bool isDeviceRegistered;
  bool isAdmin;

  RedirectionData(
      {this.firstTime = false,
      this.loggedIn = false,
      this.isInstaller = false,
      this.isDeviceRegistered = false,
      this.isAdmin = false});
}

class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<RedirectionPage> createState() => _RedirectionPageState();
}

class _RedirectionPageState extends State<RedirectionPage> {
  late LocalStorageService localStorageService;
  late DiretoDaNuvemAPI diretoDaNuvemAPI;
  late SignInService signInService;
  Future<bool>? isFirstTime;

  int i = 0;

  getDependencies() {
    localStorageService =
        Provider.of<LocalStorageService>(context, listen: false);
    signInService = Provider.of<SignInService>(context, listen: false);
    diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen: false);
  }

  Future<bool> getIsFirstTime() async {
    bool firstTime =
        await localStorageService.readBool(LocalStorageBooleans.firstTime) ??
            true;
    return firstTime;
  }

  @override
  void initState() {
    super.initState();
    getDependencies();
    setState(() {
      isFirstTime = getIsFirstTime();
    });
  }

  ChangeNotifier createUserController(BuildContext context) {
    final u = UserController(context.read(), context.read());
    u.getUserPrivileges();
    return u;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserController>(create: (context) {
          final u = UserController(context.read(), context.read());
          if (u.isLoggedIn) {
            u.getUserPrivileges();
          }
          return u;
        }),
        ChangeNotifierProvider<DeviceController>(create: (context) {
          final d = DeviceController(context.read());
          d.init();
          return d;
        })
      ],
      child: Consumer2<UserController, DeviceController>(
        builder: (context, userController, deviceController, child) {
          RedirectionData redirectionData = RedirectionData();
          redirectionData.isAdmin = userController.isAdmin;
          redirectionData.loggedIn = userController.isLoggedIn;
          redirectionData.isInstaller = userController.isInstaller;
          redirectionData.isDeviceRegistered = deviceController.isRegistered;
          return FutureBuilder(
            future: isFirstTime,
            builder: (c, s) => redirectionBuilder(c, s, redirectionData),
          );
        },
      ),
    );
  }

  Widget redirectionBuilder(BuildContext c, AsyncSnapshot<bool> snapshot,
      RedirectionData redirectionData) {
    if (snapshot.data == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    redirectionData.firstTime = snapshot.data ?? true;
    return handleRedirection(redirectionData);
  }

  Widget loading() {
    return const Center(child: CircularProgressIndicator());
  }

  //TODO: Fix Blink
  Widget handleRedirection(RedirectionData redirectionData) {
    if (redirectionData.firstTime) {
      return const IntroPage();
    }
    if (!redirectionData.loggedIn) {
      return const LoginPage();
    }
    if (!redirectionData.isDeviceRegistered) {
      if (redirectionData.isInstaller) {
        return const RegisterDevicePage();
      } else {
        return const UnregisteredDeviceErrorPage();
      }
    }
    if (redirectionData.isAdmin) {
      return const DashboardPage();
    }
    return const QueueViewPage();
  }
}
