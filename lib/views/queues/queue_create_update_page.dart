import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/utils/loading_widget.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/widgets/image_list_tile.dart';
import 'package:ddnuvem/views/queues/queue_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueCreateUpdatePage extends StatelessWidget {
  const QueueCreateUpdatePage(
      {super.key, required this.queue,
        required this.onSave,
        this.onDelete,
        this.onModerate,
        this.isActive = false
      });

  final Queue queue;
  final bool isActive;
  final void Function(Queue) onSave;
  final void Function(Queue)? onDelete;
  final void Function(Queue)? onModerate;

  @override
  Widget build(BuildContext context) {
    String titleAction = queue.id.isEmpty ? "Criar" : "Editar";
    final isSuperAdmin = context.read<UserController>()
        .isCurrentUserSuperAdmin();

    return ChangeNotifierProvider(
      create: (context) => QueueEditController(
        context: context,
        queue: queue,
      ),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text("$titleAction fila"),
          actions: [
            queue.id.isNotEmpty && !isActive ?
            IconButton(
              color: AppTheme.primaryRed,
              onPressed: () {
                _showDeleteDialog(context);
              },
              icon: const Icon(Icons.delete),
            ) : const SizedBox.shrink(),
            IconButton(
              color: AppTheme.primaryBlue,
              icon: const Icon(Icons.save),
              onPressed: () {
                var controller =
                    context.read<QueueEditController>();
                if (!controller
                    .formKey
                    .currentState!
                    .validate()) {
                  return;
                }
                controller.queue.name = controller.nameController.text;
                onSave(context.read<QueueEditController>().queue);
              },
            ),
          ],
        ),
        floatingActionButton: Column (
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isSuperAdmin && queue.id.isNotEmpty
                && queue.status == QueueStatus.pending ?
            FloatingActionButton(
              heroTag: "moderate",
              onPressed: () {
                _showModerationDialog(context);
              },
              backgroundColor: Colors.orange,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              tooltip: "Moderar fila",
              child: const Icon(Icons.error),
            ) : const SizedBox.shrink(),
            const SizedBox(height: 5),
            FloatingActionButton(
              heroTag: "addImage",
              onPressed: context.read<QueueEditController>().pickImage,
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              tooltip: "Adicionar Imagem",
              child: const Icon(Icons.add),
            ),
          ]
        ),
        body: Consumer<QueueEditController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                Form(
                  key: controller.formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                      controller: controller.nameController,
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
                ),
                Expanded(
                  child: controller.imagesLoaded ? ReorderableListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 70),
                    onReorder: controller.reorderQueue,
                    children: controller.queue.images.map((image) {
                      if (image.data == null) {
                        return const CircularProgressIndicator();
                      }
                      return ImageListTile(
                        image: image,
                        key: Key(image.path),
                      );
                    }).toList(),
                  ) : loadingWidget(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir fila"),
          content: const Text("Você deseja excluir esta fila?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar", style: TextStyle(
                  color: AppTheme.primaryBlue)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (onDelete != null) {
                  onDelete!(queue);
                }
              },
              child: const Text("Excluir",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed)),
            ),
          ],
        );
      },
    );
  }

  _showModerationDialog(BuildContext context) {
    var controller = context.read<QueueEditController>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Moderar fila"),
          content: const Text("Você deseja aprovar ou rejeitar esta fila?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar", style: TextStyle(
                  color: AppTheme.primaryBlue)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                controller.queue.status = QueueStatus.rejected;
                onModerate!(controller.queue);
              },
              child: const Text("Rejeitar",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                controller.queue.status = QueueStatus.approved;
                onModerate!(controller.queue);
              },
              child: const Text("Aprovar",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}
