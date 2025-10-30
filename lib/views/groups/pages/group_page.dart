import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/widgets/custom_snackbar.dart';
import 'package:ddnuvem/utils/widgets/no_connection_dialog.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/groups/pages/group_create_page.dart';
import 'package:ddnuvem/views/queues/widgets/queue_card.dart';
import 'package:ddnuvem/views/queues/pages/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    Group? group;

    try {
      group = ModalRoute.of(context)!.settings.arguments as Group;
    } catch (_) {
      return const SizedBox.shrink();
    }

    return Consumer3<GroupController, UserController, ConnectionService>(
      builder: (context, groupController, userController, connection, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(group!.name),
            actions: [
              IconButton(
                onPressed: () {
                  connection.connectionStatus
                    ? _pushEditGroupPage(context, group!)
                    : noConnectionDialog(context).show();
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              connection.connectionStatus
                  ? _pushCreateQueuePage(context, group!)
                  : noConnectionDialog(context).show();
            },
            backgroundColor: AppTheme.primaryBlue,
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
                    queueCardForActiveQueue(context, group!),
                    const SizedBox(height: 8),
                    Text(
                      "Outras filas",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    otherQueuesList(context, group),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget queueCardForActiveQueue(BuildContext context, Group group) {
    final queueController = context.read<QueueController>();
    Queue? queue;

    for (var q in queueController.queues) {
      if (q.id == group.currentQueue) {
        queue = q;
      }
    }
    if (queue == null) {
      return const Text("Nenhuma fila associada a este grupo");
    }
    return QueueCard(
      queue: queue,
      group: group,
      isActive: true,
    );
  }

  Widget otherQueuesList(BuildContext context, Group group) {
    final queueController = context.read<QueueController>();

    final otherQueues = queueController.queues
        .where((element) =>
            element.groupId == group.id &&
            element.id != group.currentQueue)
        .map((e) => QueueCard(queue: e, group: group,));

    return Column(
      children: otherQueues.toList(),
    );
  }

  _pushEditGroupPage(BuildContext context, Group group) {
    final groupController = context.read<GroupController>();
    final userController = context.read<UserController>();
    final snackBar = CustomSnackbar(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return GroupCreatePage(
            group: Group.copy(group),
            onSave: (group) async {
              String text;
              try {
                await groupController.updateGroup(group);
                await userController.grantAdminPrivilege(group.admins);
                text = "Grupo atualizado com sucesso!";
              } catch (e) {
                text = e.toString();
              }
              snackBar.buildMessage(text);
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/',
                        (route) => false,
                    arguments: {'startIndex': 1});
              }
            },
          );
        },
      ),
    );
  }

  _pushCreateQueuePage(BuildContext context, Group group) {
    final queueController = context.read<QueueController>();
    final snackBar = CustomSnackbar(context);
    String text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QueueCreateUpdatePage(
          queue: Queue.empty(),
          onSave: (queue) async {
            queue.groupId = group.id;
            try {
              await queueController.createQueue(queue);
              text = "Fila criada com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
          },
        ),
      ),
    );
  }
}
