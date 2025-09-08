import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/local_storage_service.dart';
import 'package:ddnuvem/utils/loading_widget.dart';
import 'package:ddnuvem/views/admin/admin_page.dart';
import 'package:ddnuvem/views/devices/register_device_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/queues/queue_view_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:ddnuvem/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class RedirectionData {
  bool loggedIn;
  bool isInstaller;
  bool isDeviceRegistered;
  bool isSmartphone;
  bool isAdmin;
  bool isLoading;
  bool initialized;
  String packageVersion;
  String groupTitle;
  String queueTitle;

  RedirectionData({
    this.loggedIn = false,
    this.isInstaller = false,
    this.isDeviceRegistered = false,
    this.isSmartphone = false,
    this.isAdmin = false,
    this.isLoading = true,
    this.initialized = false,
    this.packageVersion = "",
    this.queueTitle = "",
    this.groupTitle = ""
  });
}

class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<RedirectionPage> createState() => _RedirectionPageState();
}

class _RedirectionPageState extends State<RedirectionPage> {
  late LocalStorageService localStorageService;
  late DiretoDaNuvemAPI diretoDaNuvemAPI;
  String version = "";

  getDependencies() {
    localStorageService = context.read<LocalStorageService>();
    diretoDaNuvemAPI =  context.read<DiretoDaNuvemAPI>();
  }

  _getPackageVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    getDependencies();
    _getPackageVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserController, DeviceController, GroupController>(
      builder:
          (context, userController, deviceController, groupController, child) {
        RedirectionData redirectionData = RedirectionData();

        redirectionData.packageVersion = version;
        redirectionData.loggedIn = userController.isLoggedIn;

        if (redirectionData.loggedIn) {
          redirectionData.isAdmin = userController.isCurrentUserAdmin();
          redirectionData.isInstaller = userController.isCurrentUserInstaller();
        }

        redirectionData.isDeviceRegistered = deviceController.isRegistered;
        redirectionData.isSmartphone = deviceController.isSmartphone;
        redirectionData.isLoading = deviceController.loadingInitialState ||
            userController.loadingInitialState;

        if (redirectionData.isDeviceRegistered) {
          redirectionData.initialized = deviceController.showedSplash;
          redirectionData.queueTitle = deviceController.currentQueue != null
              ? deviceController.currentQueue!.name : "";
          redirectionData.groupTitle = deviceController.group != null
              ? deviceController.group!.name : "";
        }
        return Builder(
          builder: (c) => redirectionBuilder(redirectionData),
        );
      },
    );
  }

  Widget redirectionBuilder(RedirectionData redirectionData) {
    if (redirectionData.isLoading) {
      return loadingWidget(context);
    }

    return handleRedirection(redirectionData);
  }

  Widget handleRedirection(RedirectionData redirectionData) {
    if (!redirectionData.loggedIn) {
      return IntroPage(packageVersion: redirectionData.packageVersion);
    }
    if (!redirectionData.isDeviceRegistered && redirectionData.isInstaller) {
      return const RegisterDevicePage();
    }
    if (redirectionData.isAdmin && redirectionData.isSmartphone) {
      return const AdminPage();
    }
    if (!redirectionData.initialized && redirectionData.isDeviceRegistered) {
      return SplashScreen(
          group: redirectionData.groupTitle,
          packageVersion: redirectionData.packageVersion,
          queue: redirectionData.queueTitle
      );
    }
    return ChangeNotifierProvider(
      create: (context) => QueueViewController(
        diretoDaNuvemAPI,
        context.read<DeviceController>(),
      ),
      child: Consumer<QueueViewController>(
        builder: (context, controller, _) {
          return QueueViewPage(queue: controller.queue);
        },
      )
    );
  }
}
