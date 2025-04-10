import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/views/queues/image_list_tile.dart';
import 'package:ddnuvem/views/queues/queue_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueEditPage extends StatelessWidget {
  const QueueEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QueueEditController(
        diretoDaNuvemAPI: context.read(),
        queue: context.read<QueueController>().selectedQueue!,
      ),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Editar Fila"),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                context.read<QueueEditController>().saveQueue();
                Navigator.pop(context);
              },
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow))
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
            return ReorderableListView(
              padding: const EdgeInsets.all(16),
              onReorder: controller.reorderQueue,
              children: controller.images.map((image) {
                return ImageListTile(
                  image: image,
                  key: Key(image.path),
                );
              }).toList(),
            );
          }
        ),
      ),
    );
  }
}