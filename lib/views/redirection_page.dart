import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/utils/widgets/loading_widget.dart';
import 'package:ddnuvem/views/admin/admin_page.dart';
import 'package:ddnuvem/views/devices/pages/register_device_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/queues/controllers/queue_view_controller.dart';
import 'package:ddnuvem/views/queues/pages/queue_view_page.dart';
import 'package:ddnuvem/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class RedirectionData {
  bool loggedIn;
  bool isInstaller;
  bool isDeviceRegistered;
  bool isTelevision;
  bool isAdmin;
  bool isLoading;
  bool showSplash;

  RedirectionData({
    this.loggedIn = false,
    this.isInstaller = false,
    this.isDeviceRegistered = false,
    this.isTelevision = false,
    this.isAdmin = false,
    this.isLoading = true,
    this.showSplash = false,
  });
}

class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<RedirectionPage> createState() => _RedirectionPageState();
}

class _RedirectionPageState extends State<RedirectionPage> {
  late DiretoDaNuvemAPI diretoDaNuvemAPI;
  String packageVersion = "";

  _getDependencies() {
    diretoDaNuvemAPI =  context.read<DiretoDaNuvemAPI>();
  }

  _getPackageVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageVersion = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    _getPackageVersion();
    _getDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserController, DeviceController, GroupController>(
      builder:
          (context, userController, deviceController, groupController, child) {
        RedirectionData redirectionData = RedirectionData();

        redirectionData.loggedIn = userController.isLoggedIn;
        if (redirectionData.loggedIn) {
          redirectionData.isAdmin = userController.isCurrentUserAdmin();
          redirectionData.isInstaller = userController.isCurrentUserInstaller();
        }

        redirectionData.showSplash = !deviceController.showedSplash;
        redirectionData.isTelevision = deviceController.isTelevision;
        redirectionData.isDeviceRegistered = deviceController.isRegistered;

        redirectionData.isLoading = deviceController.loadingInitialState ||
            userController.loadingInitialState;
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
      return IntroPage(packageVersion: packageVersion);
    }
    if (!redirectionData.isDeviceRegistered && redirectionData.isInstaller) {
      return const RegisterDevicePage();
    }
    if (redirectionData.showSplash) {
      return SplashScreen(packageVersion: packageVersion);
    }
    if (redirectionData.isAdmin) {
      return const AdminPage();
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
