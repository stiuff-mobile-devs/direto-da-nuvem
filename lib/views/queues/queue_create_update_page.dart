import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/animation.dart' as model;
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/utils/custom_dialog.dart';
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
        this.isActive = false
      });

  final Queue queue;
  final bool isActive;
  final void Function(Queue) onSave;
  final void Function(Queue)? onDelete;

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
                var controller = context.read<QueueEditController>();
                if (!controller.formKey.currentState!.validate()) return;
                controller.queue.name = controller.nameController.text;
                controller.queue.duration = controller.durationController.text
                    .isNotEmpty
                    ? int.parse(controller.durationController.text)
                    : 10;
                controller.queue.status = isSuperAdmin
                    ? QueueStatus.approved
                    : QueueStatus.pending;
                Navigator.of(context).pop();
                onSave(controller.queue);
              },
            ),
          ],
        ),
        floatingActionButton: Column (
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isSuperAdmin && queue.id.isNotEmpty ?
            FloatingActionButton(
              heroTag: "moderate",
              onPressed: () {
                _showModerationDialog(context,queue.status);
              },
              backgroundColor: _queueStatusIcon(queue.status),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              tooltip: "Moderar fila",
              child: const Icon(Icons.local_police_outlined),
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
                    child: Column(
                      children: [
                        TextFormField(
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
                        const SizedBox(height: 10),
                        _buildDropDownMenu(context,controller),
                        const SizedBox(height: 10),
                        Row (
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Digite apenas números';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                controller: controller.durationController,
                                decoration: const InputDecoration(
                                  floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                                  labelText: 'Duração',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'segundo(s)',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: controller.imagesLoaded
                      ? ReorderableListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 70),
                          onReorder: controller.reorderQueue,
                          children: controller.queue.images.map((image) {
                            if (image.data == null) {
                              return const SizedBox.shrink();
                            }
                            return ImageListTile(
                              image: image,
                              key: Key(image.path),
                            );
                          }).toList(),
                        )
                      : loadingWidget(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _buildDropDownMenu(BuildContext context, QueueEditController c) {
    List<String> options = model.Animation.getAnimationOptionsList();
    List<DropdownMenuEntry<String>> entries = options.map((e) {
        return DropdownMenuEntry<String>(value: e, label: e);
      },
    ).toList();

    return DropdownMenu<String>(
      initialSelection: c.queue.animation,
      width: MediaQuery.of(context).size.width - 16,
      dropdownMenuEntries: entries,
      onSelected: c.selectAnimation,
      label: const Text("Animação"),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelStyle: TextStyle(color: Colors.blueGrey),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 2),
        ),
      ),
    );
  }

  _showDeleteDialog(BuildContext context) {
    customDialog(
      context,
      "Excluir fila?",
      "Você deseja excluir esta fila?",
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (onDelete != null) onDelete!(queue);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: AppTheme.primaryRed,
                visualDensity: VisualDensity.compact
            ),
            child: const Text("Excluir", style: TextStyle(
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

  _showModerationDialog(BuildContext context, QueueStatus status) {
    var controller = context.read<QueueEditController>();
    customDialog(
      context,
      "Moderar fila",
      "Esta fila está ${_queueStatusString(status)}.",
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              controller.queue.status = QueueStatus.approved;
              onSave(controller.queue);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
                backgroundColor: Colors.green,
                visualDensity: VisualDensity.compact
            ),
            child: const Text("Aprovar", style: TextStyle(
                color: Colors.white)),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              controller.queue.status = QueueStatus.rejected;
              onSave(controller.queue);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
                backgroundColor: AppTheme.primaryRed,
                visualDensity: VisualDensity.compact
            ),
            child: const Text("Rejeitar", style: TextStyle(
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

  _queueStatusIcon(QueueStatus status) {
    switch (status) {
      case QueueStatus.approved:
        return Colors.green;
      case QueueStatus.rejected:
        return AppTheme.primaryRed;
      case QueueStatus.pending:
        return Colors.orange;
    }
  }

  _queueStatusString(QueueStatus status) {
    switch (status) {
      case QueueStatus.approved:
        return "aprovada";
      case QueueStatus.rejected:
        return "rejeitada";
      case QueueStatus.pending:
        return "pendente";
    }
  }
}
