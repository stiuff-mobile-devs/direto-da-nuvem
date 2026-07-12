import 'package:ddnuvem/controllers/external_queue_controller.dart';
import 'package:ddnuvem/models/external_queue.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/widgets/custom_dialog.dart';
import 'package:ddnuvem/utils/widgets/custom_snackbar.dart';
import 'package:ddnuvem/utils/widgets/no_connection_dialog.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/pages/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExternalQueueCard extends StatelessWidget {
  const ExternalQueueCard({
    super.key,
    required this.queue,
    this.isActive = false
  });

  final ExternalQueue queue;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
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
            _showActivateQueueDialog(context, numberOfPhotos);
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
              _popUpMenuButton(context, connection.connectionStatus)
            ],
          ),
        ),
      ),
    );
  }

  Widget _popUpMenuButton(BuildContext context, bool connectionStatus) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (!connectionStatus) {
          noConnectionDialog(context).show();
        } else {
          if (value == "edit") {
            _pushUpdateQueuePage(context);
          } else {
            _createCopyDialog(context);
          }
        }
      },
      itemBuilder: (context) => [
        if (!isActive) ...[
          const PopupMenuItem(
            value: "edit",
            child: Row (
              children: [
                Icon(Icons.edit),
                SizedBox(width: 10),
                Text("Editar"),
              ],
            ),
          ),
        ],
        // const PopupMenuItem(
        //   value: "copy",
        //   child: Row (
        //     children: [
        //       Icon(Icons.copy),
        //       SizedBox(width: 10),
        //       Text("Copiar"),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  _pushUpdateQueuePage(BuildContext context) {
    final controller = context.read<ExternalQueueController>();
    Queue q = Queue.fromExternalQueue(queue);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QueueCreateUpdatePage(
          queue: q,
          isActive: isActive,
          isLastOne: controller.totalQueues() == 1,
          onSave: (queue) async {
            final snackBar = CustomSnackbar(context);
            String text;
            final updatedQueue = ExternalQueue.fromQueue(queue);
            try {
              await controller.updateQueue(updatedQueue);
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
            final toDeleteQueue = ExternalQueue.fromQueue(queue);
            try {
              await controller.deleteQueue(toDeleteQueue);
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

  _showActivateQueueDialog(BuildContext context, String numberOfPhotos) {
    final controller = context.read<ExternalQueueController>();
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
                  controller.updateCurrentQueue(queue.id);
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

  _createCopyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        GlobalKey<FormState> formKey = GlobalKey<FormState>();
        final TextEditingController controller = TextEditingController();

        return AlertDialog(
          title: const Text("Criar cópia da fila", textAlign: TextAlign.center),
          content: Form(
            key: formKey,
            child: TextFormField(
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (value == queue.name) {
                  return 'O nome precisa ser diferente';
                }
                return null;
              },
              controller: controller,
              decoration: const InputDecoration(
                floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                labelText: 'Nome da Fila',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),
          ),
          actions: [
            Center (
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(context);
                        await _createCopy(queue, controller.text, context);
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          backgroundColor: AppTheme.primaryBlue,
                          visualDensity: VisualDensity.compact
                      ),
                      child: const Text("Criar fila", style: TextStyle(
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
                  ]
              ),
            )
          ],
        );
      },
    );
  }

  _createCopy(ExternalQueue queue, String newName, BuildContext context) async {
    final queueController = context.read<ExternalQueueController>();
    final snackBar = CustomSnackbar(context);
    String snackBarText;

    ExternalQueue newQueue = ExternalQueue.copy(queue);
    newQueue.name = newName;
    newQueue.createdAt = DateTime.now();

    try {
      await queueController.createQueue(newQueue);
      snackBarText = "Cópia criada com sucesso!";
    } catch (e) {
      snackBarText = e.toString();
    }
    snackBar.buildMessage(snackBarText);
  }
}
