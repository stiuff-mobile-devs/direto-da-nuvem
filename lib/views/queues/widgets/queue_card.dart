import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/custom_snackbar.dart';
import 'package:ddnuvem/utils/no_connection_dialog.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueCard extends StatelessWidget {
  const QueueCard({super.key,
    required this.group, required this.queue, this.isActive = false});

  final Queue queue;
  final Group group;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final connection = context.read<ConnectionService>();
    String numberOfPhotos = queue.images.length == 1
        ? "${queue.images.length} foto"
        : "${queue.images.length} fotos";

    return GestureDetector(
      onTap: () {
        if (!isActive && queue.status == QueueStatus.approved) {
          connection.connectionStatus
              ? _showDialog(context, numberOfPhotos)
              : noConnectionDialog(context).show();
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!queue.updated)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        queue.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        numberOfPhotos,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _queueStatusIcon(queue.status),
                  IconButton(
                    onPressed: () {
                      !connection.connectionStatus
                        ? noConnectionDialog(context).show()
                        : _pushUpdateQueuePage(context);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _pushUpdateQueuePage(BuildContext context) {
    final isSuperAdmin = context.read<UserController>().isCurrentUserSuperAdmin();
    final controller = context.read<QueueController>();
    final snackBar = CustomSnackbar(context);
    String text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QueueCreateUpdatePage(
          queue: queue,
          isActive: isActive,
          onSave: (queue) async {
            queue.status = isSuperAdmin
                ? QueueStatus.approved
                : QueueStatus.pending;
            try {
              await controller.updateQueue(queue);
              text = "Fila atualizada com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
          },
          onDelete: (queue) async {
            Navigator.pop(context);
            try {
              await controller.deleteQueue(queue.id);
              text = "Fila excluída com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
          },
          onModerate: (queue) async {
            Navigator.pop(context);
            try {
              await controller.updateQueue(queue);
              text = "Fila atualizada com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
          },
        ),
      ),
    );
  }

  _showDialog(BuildContext context, String numberOfPhotos) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Tornar esta fila ativa?"),
          content: Text("Esta fila possui $numberOfPhotos."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Fechar",
                  style: TextStyle(color: AppTheme.primaryRed)),
            ),
            TextButton(
              onPressed: () async {
                final snackBar = CustomSnackbar(context);
                String text;
                try {
                  await context.read<GroupController>()
                      .updateCurrentQueue(group, queue.id);
                  text = "Fila ativa atualizada com sucesso!";
                } catch (e) {
                  text = e.toString();
                }
                snackBar.buildMessage(text);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Sim", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue)),
            ),
          ],
        );
      });
  }
  
  _queueStatusIcon(QueueStatus status) {
    switch (status) {
      case QueueStatus.approved:
        return const Icon(Icons.check_circle, color: Colors.green);
      case QueueStatus.rejected:
        return const Icon(Icons.cancel, color: AppTheme.primaryRed);
      case QueueStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }
}
