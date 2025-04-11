import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  bool showView = true;
  
  @override
  Widget build(BuildContext context) {
    if (showView) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showView = false;
        });
      },
      child: Consumer<QueueViewController>(
        builder: (context, controller, _) => QueueViewPage(
          queue: controller.queue,
        ),
      ),
    );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              showView = true;
            });
          },
          child: const Text("Play"),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<UserController>().logout();
          },
          child: const Text("Sair"),
        ),
      ],
    );
  }
}
