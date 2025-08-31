import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueCard extends StatelessWidget {
  const QueueCard({super.key, required this.queue, this.isActive = false});

  final Queue queue;
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
              : connection.noConnectionDialog(context).show();
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
                        ? connection.noConnectionDialog(context).show()
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
    final messenger = ScaffoldMessenger.of(context);
    final isSuperAdmin = context.read<UserController>()
        .currentUser!.privileges.isSuperAdmin;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QueueCreateUpdatePage(
          queue: queue,
          isActive: isActive,
          onSave: (queue) {
            queue.status = isSuperAdmin
                ? QueueStatus.approved
                : QueueStatus.pending;

            context.read<QueueController>()
                .updateQueue(queue).then((message) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            });
            Navigator.pop(context);
          },
          onDelete: (queue) {
            context.read<QueueController>().deleteQueue(queue.id).then((message) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            });
            Navigator.pop(context);
          },
          onModerate: (queue) {
            context.read<QueueController>()
                .updateQueue(queue).then((message) {
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
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                context.read<GroupController>()
                    .makeQueueCurrent(queue.id).then((message) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(message),
                    ),
                  );
                });
                Navigator.pop(context);
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
