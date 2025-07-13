import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:ddnuvem/views/admin/admin_page.dart';
import 'package:ddnuvem/views/devices/register_device_page.dart';
import 'package:ddnuvem/views/devices/unregistered_device_error_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/login_page.dart';
import 'package:ddnuvem/views/queues/monitor_page.dart';
import 'package:ddnuvem/views/queues/queue_stream_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedirectionData {
  bool firstTime;
  bool loggedIn;
  bool isInstaller;
  bool isDeviceRegistered;
  bool isAdmin;
  bool isLoading;

  RedirectionData(
      {this.firstTime = false,
      this.loggedIn = false,
      this.isInstaller = false,
      this.isDeviceRegistered = false,
      this.isAdmin = false,
      this.isLoading = true});
}

class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<RedirectionPage> createState() => _RedirectionPageState();
}

class _RedirectionPageState extends State<RedirectionPage> {
  late LocalStorageService localStorageService;
  late DiretoDaNuvemAPI diretoDaNuvemAPI;
  Future<bool>? isFirstTime;

  int i = 0;

  getDependencies() {
    localStorageService =
        Provider.of<LocalStorageService>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserController, DeviceController, GroupController>(
      builder: (context, userController, deviceController, groupController, child) {
        RedirectionData redirectionData = RedirectionData();
        redirectionData.isAdmin = userController.isSuperAdmin || userController.isAdmin;
        redirectionData.loggedIn = userController.isLoggedIn;
        redirectionData.isInstaller = userController.isInstaller;
        redirectionData.isDeviceRegistered = deviceController.isRegistered;
        redirectionData.isLoading = deviceController.loadingInitialState ||
            userController.loadingInitialState;
        return FutureBuilder(
          future: isFirstTime,
          builder: (c, s) => redirectionBuilder(c, s, redirectionData),
        );
      },
    );
  }

  Widget redirectionBuilder(BuildContext c, AsyncSnapshot<bool> snapshot,
      RedirectionData redirectionData) {
    if (snapshot.data == null || redirectionData.isLoading) {
      return loading();
    }
    redirectionData.firstTime = snapshot.data ?? true;
    return handleRedirection(redirectionData);
  }

  Widget loading() {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

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
      }
      if (redirectionData.isAdmin) {
        return const AdminPage();
      }
      return const UnregisteredDeviceErrorPage();
    }
    if (redirectionData.isAdmin) {
      return const AdminPage();
    }
    var deviceController = context.read<DeviceController>();

    Stream<Queue?>? queueStream = deviceController.currentQueueStream;
    Queue? queue = deviceController.currentQueue;
    if (queueStream == null || queue == null) {
      return loading();
    }
    return ChangeNotifierProvider(
      create: (context) => QueueStreamViewController(
        diretoDaNuvemAPI,
        queue,
        queueStream,
      ),
      child: const MonitorPage(),
    );
  }
}
