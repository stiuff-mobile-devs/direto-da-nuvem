import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/admin/admin_page.dart';
import 'package:ddnuvem/views/devices/register_device_page.dart';
import 'package:ddnuvem/views/devices/unregistered_device_error_page.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/queues/queue_view_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedirectionData {
  bool loggedIn;
  bool isInstaller;
  bool isDeviceRegistered;
  bool isAdmin;
  bool isLoading;

  RedirectionData({
    this.loggedIn = false,
    this.isInstaller = false,
    this.isDeviceRegistered = false,
    this.isAdmin = false,
    this.isLoading = true
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

  getDependencies() {
    localStorageService = context.read<LocalStorageService>();
    diretoDaNuvemAPI =  context.read<DiretoDaNuvemAPI>();
  }

  @override
  void initState() {
    super.initState();
    getDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserController, DeviceController, GroupController>(
      builder:
          (context, userController, deviceController, groupController, child) {
        RedirectionData redirectionData = RedirectionData();

        redirectionData.loggedIn = userController.isLoggedIn;

        if (redirectionData.loggedIn) {
          final privileges = userController.currentUser!.privileges;
          redirectionData.isAdmin =
              privileges.isSuperAdmin || privileges.isAdmin;
          redirectionData.isInstaller = privileges.isInstaller;
        }

        redirectionData.isDeviceRegistered = deviceController.isRegistered;
        redirectionData.isLoading = deviceController.loadingInitialState ||
            userController.loadingInitialState;

        return Builder(
          builder: (c) => redirectionBuilder(c, redirectionData),
        );
      },
    );
  }

  Widget redirectionBuilder(BuildContext c, RedirectionData redirectionData) {
    if (redirectionData.isLoading) {
      return loading();
    }

    return handleRedirection(redirectionData);
  }

  // Aparece quando abrimos o app
  Widget loading() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      ),
    );
  }

  Widget handleRedirection(RedirectionData redirectionData) {
    if (!redirectionData.loggedIn) {
      return const IntroPage();
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

    return ChangeNotifierProvider(
      create: (context) => QueueViewController(
        diretoDaNuvemAPI,
        context.read<DeviceController>(),
      ),
      child: Consumer<QueueViewController>(
        builder: (context, controller, _) {
          return QueueViewPage(queue: controller.queue!);
        },
      )
    );
  }
}
