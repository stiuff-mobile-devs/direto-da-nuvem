import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/views/queues/queue_view_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                leading:
                    Consumer<UserController>(builder: (context, controller, _) {
                  final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
                  return CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null ? const Icon(Icons.person) : null,
                  );
                }),
                title: const Text("Perfil"),
                subtitle:
                    Consumer<UserController>(builder: (context, controller, _) {
                  return Text("logado como ${controller.userEmail}");
                }),
                onTap: () {
                  // TODO
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
              ),
            ],
          );
        }),
      ),
    );
  }
}
