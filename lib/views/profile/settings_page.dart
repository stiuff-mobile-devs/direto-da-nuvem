import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/views/queues/queue_view_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

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
                subtitle: Text("Logado como $email"),
                onTap: () {
                  // Navigator.pushNamed(context, "/profile");
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () => controller.logout(),
              ),
              kDebugMode
              ? ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text("Tocar fila"),
                  enabled: isRegistered,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ChangeNotifierProvider<QueueViewController>(
                            create: (_) => QueueViewController(
                              context.read<DiretoDaNuvemAPI>(),
                              context.read<DeviceController>(),
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
