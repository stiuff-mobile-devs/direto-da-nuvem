import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/widgets/custom_dialog.dart';
import 'package:ddnuvem/utils/widgets/custom_snackbar.dart';
import 'package:ddnuvem/utils/widgets/no_connection_dialog.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/pages/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/moderate_queue_page.dart';

class QueueCard extends StatelessWidget {
  const QueueCard({
    super.key,
    required this.group,
    required this.queue,
    this.isActive = false
  });

  final Queue queue;
  final Group group;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final userController = context.read<UserController>();
    final superAdmin = userController.isCurrentUserSuperAdmin();
    final isAdmin = group.admins.contains(userController.currentUser!.email);
    final connection = context.read<ConnectionService>();
    String numberOfPhotos = queue.images.length == 1
        ? "${queue.images.length} foto"
        : "${queue.images.length} fotos";

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          if (!connection.connectionStatus) {
            noConnectionDialog(context).show();
          } else {
            queue.status == QueueStatus.approved
                ? _showActivateQueueDialog(context, numberOfPhotos)
                : _showPendingQueueDialog(context, queue.status);
          }
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
                  IconButton(
                    onPressed: () {
                      if (superAdmin) {
                        !connection.connectionStatus
                            ? noConnectionDialog(context).show()
                            : _pushModerateQueuePage(context);
                      }
                    },
                    icon: _queueStatusIcon(queue.status),
                  ),
                  if (!isActive && isAdmin) ...[
                    IconButton(
                      onPressed: () {
                        !connection.connectionStatus
                            ? noConnectionDialog(context).show()
                            : _pushUpdateQueuePage(context);
                      },
                      icon: const Icon(Icons.edit))
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _pushUpdateQueuePage(BuildContext context) {
    final controller = context.read<QueueController>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QueueCreateUpdatePage(
          queue: Queue.copy(queue),
          isActive: isActive,
          isLastOne: controller.totalQueuesOnGroup(queue.groupId) == 1,
          onSave: (queue) async {
            Navigator.pop(context);
            final snackBar = CustomSnackbar(context);
            String text;
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
            final snackBar = CustomSnackbar(context);
            String text;
            try {
              await controller.deleteQueue(queue.id);
              text = "Fila excluída com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
          },
        ),
      ),
    );
  }

  _pushModerateQueuePage(BuildContext context) {
    final controller = context.read<QueueController>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModerateQueuePage(
          queue: Queue.copy(queue),
          onSave: (queue) async {
            Navigator.pop(context);
            final snackBar = CustomSnackbar(context);
            String text;
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

  _showActivateQueueDialog(BuildContext context, String numberOfPhotos) {
    customDialog(context,
      "Tornar fila ativa?",
      "Esta fila possui $numberOfPhotos.",
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
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
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: AppTheme.primaryBlue,
                visualDensity: VisualDensity.compact
            ),
            child: const Text("Confirmar", style: TextStyle(
                color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: const Text("Fechar", style: TextStyle(
                color: AppTheme.primaryBlue)),
          ),
        ],
      )
    );
  }

  _showPendingQueueDialog(BuildContext context, QueueStatus status) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: "Fila ${queueStatusString(status)}",
      desc: 'Somente filas aprovadas por um superadministrador podem ser ativadas.',
    ).show();
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
