import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/views/queues/image_list_tile.dart';
import 'package:ddnuvem/views/queues/queue_edit_controller.dart';
import 'package:ddnuvem/views/queues/queue_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueCreateUpdatePage extends StatelessWidget {
  const QueueCreateUpdatePage(
      {super.key, required this.queue, required this.onSave});
  final Queue queue;
  final void Function(Queue queue) onSave;

  @override
  Widget build(BuildContext context) {
    String titleAction = queue.id!.isEmpty ? "Criar" : "Editar";
    return ChangeNotifierProvider(
      create: (context) => QueueEditController(
        diretoDaNuvemAPI: context.read(),
        queue: queue,
      ),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text("$titleAction fila"),
          actions: [
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
}
