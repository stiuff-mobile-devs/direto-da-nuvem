import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/views/queues/queue_view_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Configurações"),
        ),
        body: Consumer<UserController>(builder: (context, controller, _) {
          return Column(
            children: [
              ListTile(
                title: const Text("Perfil"),
                subtitle:
                    Consumer<UserController>(builder: (context, controller, _) {
                  return Text("logado como ${controller.userEmail}");
                }),
                onTap: () {
                  Navigator.pushNamed(context, "/profile");
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: controller.logout,
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text("Tocar fila"),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<QueueViewController>(
                        create: (context) => QueueViewController(
                          context.read<DiretoDaNuvemAPI>(),
                          context.read<DeviceController>().currentQueue!,
                        ),
                        builder: (context, cont) {
                          QueueViewController controller =
                              Provider.of<QueueViewController>(context);
                          return QueueViewPage(
                            queue: controller.queue,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
