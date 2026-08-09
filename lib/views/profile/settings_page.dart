import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/external_queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/views/queues/controllers/external_queue_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../services/direto_da_nuvem/direto_da_nuvem_service.dart';
import '../queues/controllers/queue_view_controller.dart';
import '../queues/pages/external_queue_view_page.dart';
import '../queues/pages/queue_view_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isRegistered = context.read<DeviceController>().isRegistered;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Configurações"),
        ),
        body: Consumer2<UserController, ConnectionService>(
            builder: (context, controller, connection, _) {
          final email = controller.currentUser!.email;
          final photoUrl = controller.profileImageUrl;
          final privs = (controller.currentUser!.privileges).toString();
          final external = controller.isCurrentUserExternal();

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: connection.connectionStatus
                    ? NetworkImage(photoUrl!)
                    : null,
                  child: connection.connectionStatus
                    ? null
                    : const Icon(Icons.person)
                ),
                title: const Text("Perfil"),
                subtitle: Text("$privs\nLogado como $email"),
                onTap: () {
                  // Navigator.pushNamed(context, "/profile");
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () => controller.logout(),
              ),
              (kDebugMode || external)
              ? ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text("Tocar fila"),
                enabled: external || isRegistered,
                onTap: () {
                  if (external) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ChangeNotifierProvider<
                              ExternalQueueViewController>(
                            create: (_) => ExternalQueueViewController(
                                context.read<ExternalQueueController>(),
                                context.read<DeviceController>(),
                                context.read<ConnectionService>()),
                            child: Consumer<ExternalQueueViewController>(
                              builder: (context, controller, _) {
                                return ExternalQueueViewPage(
                                    queue: controller.queue!);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ChangeNotifierProvider<QueueViewController>(
                            create: (_) => QueueViewController(
                                context.read<DiretoDaNuvemAPI>(),
                                context.read<DeviceController>(),
                                context.read<ConnectionService>()
                            ),
                            child: Consumer<QueueViewController>(
                              builder: (context, controller, _) {
                                return QueueViewPage(queue: controller.queue!);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              )
              : const SizedBox.shrink(),
            ],
          );
        }),
      ),
    );
  }
}
