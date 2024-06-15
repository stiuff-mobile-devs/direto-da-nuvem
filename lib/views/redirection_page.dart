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
import 'package:device_info_plus/device_info_plus.dart';
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
      this.isAdmin = false})
  ;
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

  getDependencies() {
    localStorageService = Provider.of<LocalStorageService>(context, listen: false);
    signInService = Provider.of<SignInService>(context, listen: false);
    diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen: false);
  }

  Future<RedirectionData> getRedirectionData(
      UserController userController) async {
    
    bool firstTime =
        await localStorageService.readBool(LocalStorageBooleans.firstTime) ??
            true;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var info = await deviceInfo.androidInfo;

    bool registered =
        await diretoDaNuvemAPI.deviceResource.checkIfRegistered(info.id);

    RedirectionData redirectionData =
        RedirectionData(firstTime: firstTime, isDeviceRegistered: registered);

    if (!userController.isLoggedIn) {
      if (await signInService.trySignIn()) {
        userController.isLoggedIn = true;
        await userController.getUserPrivileges();
      }
    }
    return redirectionData;
  }

  @override
  void initState() {
    super.initState();
    getDependencies();
  }

  ChangeNotifier createUserController(BuildContext context) {
    final u = UserController(context.read(), context.read());
    u.getUserPrivileges();
    return u;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserController(context.read(), context.read()),
      child: Consumer<UserController>(
        builder: (context, value, child) {
          return FutureBuilder(
            future: getRedirectionData(value),
            builder: (c, snapshot) {
              if (snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              snapshot.data!.isInstaller = value.isInstaller;
              snapshot.data!.loggedIn = value.isLoggedIn;
              snapshot.data!.isAdmin = value.isAdmin || value.isSuperAdmin;
              return handleRedirection(snapshot.data!);
            },
          );
        },
      ),
    );
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
    // if (!redirectionData.isDeviceRegistered) {
    //   if (redirectionData.isInstaller) {
    //     return const RegisterDevicePage();
    //   } else {
    //     return const UnregisteredDeviceErrorPage();
    //   }
    // }
    if (redirectionData.isAdmin) {
      return const DashboardPage();
    }
    return const QueueViewPage();
  }
}
