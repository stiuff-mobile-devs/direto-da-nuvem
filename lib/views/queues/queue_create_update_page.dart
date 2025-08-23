import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/views/queues/image_list_tile.dart';
import 'package:ddnuvem/views/queues/queue_edit_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
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
        .currentUser!.privileges.isSuperAdmin;

    return ChangeNotifierProvider(
      create: (context) => QueueEditController(
        context: context,
        queue: queue,
      ),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text("$titleAction fila"),
          actions: [
            isSuperAdmin && queue.id.isNotEmpty
            && queue.status == QueueStatus.pending
                ? IconButton(
                  onPressed: () {
                    _showModerationDialog(context);
                  },
                  icon: const Icon(Icons.hourglass_empty, color: Colors.orange),
                  )
                : const SizedBox.shrink(),
            queue.id.isNotEmpty && !isActive ?
            IconButton(
              onPressed: () {
                _showDeleteDialog(context);
              },
              icon: const Icon(Icons.delete),
            ) : const SizedBox.shrink(),
            IconButton(
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
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QueueViewPage(
                        queue: context.read<QueueEditController>().queue),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: context.read<QueueEditController>().pickImage,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          tooltip: "Adicionar Imagem",
          child: const Icon(Icons.add),
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
                        labelText: 'Nome da Fila',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: controller.imagesLoaded ? ReorderableListView(
                    padding: const EdgeInsets.all(16),
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
                  ) : const Center(
                      child: CircularProgressIndicator.adaptive(),
                  ),
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
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (onDelete != null) {
                  onDelete!(queue);
                }
              },
              child: const Text("Excluir",
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: const Text("Cancelar"),
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
