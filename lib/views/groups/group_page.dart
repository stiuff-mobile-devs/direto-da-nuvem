import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/views/groups/group_create_page.dart';
import 'package:ddnuvem/views/queues/queue_card.dart';
import 'package:ddnuvem/views/queues/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GroupController, UserController>(
      builder: (context, groupController, userController,_) {
        return Scaffold(
          appBar: AppBar(
            title: Text(groupController.selectedGroup!.name),
            actions: [
              IconButton(
                onPressed: () {
                  _showDeleteDialog(context, groupController);
                },
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () {
                  _pushEditGroupPage(context);
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _pushCreateQueuePage(context),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<QueueController>(
              builder: (context, queueController, _) {
                return ListView(
                  padding: const EdgeInsets.only(bottom: 70),
                  children: [
                    Text(
                      "Fila ativa",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    queueCardForActiveQueue(groupController, queueController),
                    const SizedBox(height: 8),
                    Text(
                      "Outras filas",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    otherQueuesList(groupController, queueController),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget queueCardForActiveQueue(
      GroupController groupController, QueueController queueController) {
    Queue? queue;
    for (var q in queueController.queues) {
      if (q.id == groupController.selectedGroup!.currentQueue) {
        queue = q;
      }
    }
    if (queue == null) {
      return const Text("Nenhuma fila associada a este grupo");
    }
    return QueueCard(
      queue: queue,
      isActive: true,
    );
  }

  Widget otherQueuesList(
      GroupController groupController, QueueController queueController) {
    final otherQueues = queueController.queues
        .where((element) =>
            element.groupId == groupController.selectedGroup!.id &&
            element.id != groupController.selectedGroup!.currentQueue)
        .map((e) => QueueCard(queue: e));

    return Column(
      children: otherQueues.toList(),
    );
  }

  _pushEditGroupPage(BuildContext context) {
    GroupController groupController = context.read<GroupController>();
    UserController userController = context.read<UserController>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return GroupCreatePage(
            group: Group.copy(groupController.selectedGroup!),
            onSave: (group) {
              final messenger = ScaffoldMessenger.of(context);
              _onCreateGroup(
                group, userController, groupController).then(
                    (message) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(message),
                    ),
                  );
                });
              Navigator.pop(context);
            }
          );
        },
      ),
    );
  }

  _pushCreateQueuePage(BuildContext context) {
    GroupController groupController = context.read<GroupController>();
    QueueController queueController = context.read<QueueController>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QueueCreateUpdatePage(
          queue: Queue.empty(),
          onSave: (queue) {
            final messenger = ScaffoldMessenger.of(context);
            queue.groupId = groupController.selectedGroup!.id;
            queueController.saveQueue(queue).then((message) {
              messenger.showSnackBar(
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

  Future<String> _onCreateGroup(group, userController, groupController) async {
    String message = await groupController.updateGroup(group);
    await userController.updateGroupAdmins(group.admins);
    return message;
  }

  _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir grupo"),
          content: const Text("Você deseja excluir este grupo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                context.read<QueueController>().deleteQueuesByGroupId(.selectedGroup!.id);
                groupController.deleteGroup(groupController.selectedGroup!.id);
                Navigator.pop(context);
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }
}
