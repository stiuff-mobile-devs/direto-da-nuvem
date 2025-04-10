import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/views/queues/queue_card.dart';
import 'package:ddnuvem/views/queues/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  pushCreatePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QueueCreateUpdatePage(
          queue: Queue.empty(),
          onSave: (queue) {
            queue.groupId = context.read<GroupController>().selectedGroup!.id!;
            context
                .read<QueueController>()
                .saveQueue(
                  queue,
                )
                .then((message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GroupController groupController = Provider.of(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Consumer<GroupController>(builder: (context, controller, _) {
          return Text(controller.selectedGroup!.name);
        }),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pushCreatePage(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Consumer<QueueController>(builder: (context, queueController, _) {
          return ListView(
            children: queueController.queues
                .where((element) =>
                    element.groupId == groupController.selectedGroup!.id)
                .map((e) => QueueCard(queue: e))
                .toList(),
          );
        }),
      ),
    );
  }
}
