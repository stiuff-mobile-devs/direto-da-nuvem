import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/queue_status.dart';
import 'package:ddnuvem/utils/widgets/custom_dialog.dart';
import 'package:ddnuvem/utils/widgets/loading_widget.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/widgets/image_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/moderate_queue_controller.dart';

class ModerateQueuePage extends StatelessWidget {
  const ModerateQueuePage({super.key,
        required this.queue,
        required this.onSave
      });

  final Queue queue;
  final void Function(Queue) onSave;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModerateQueueController(
        context: context,
        queue: queue,
      ),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Moderar fila"),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "moderate",
          onPressed: () {
            _showModerationDialog(context,queue.status);
          },
          backgroundColor: _queueStatusIcon(queue.status),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          tooltip: "Moderar fila",
          child: const Icon(Icons.local_police_outlined),
        ),
        body: Consumer<ModerateQueueController>(
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
                          enabled: false,
                          initialValue: queue.name,
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
                        TextFormField(
                          enabled: false,
                          initialValue: queue.animation,
                          decoration: const InputDecoration(
                            floatingLabelStyle: TextStyle(color: Colors.blueGrey),
                            labelText: 'Animação',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row (
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                enabled: false,
                                initialValue: queue.duration.toString(),
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
                      ? ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 70),
                    children: controller.queue.images.map((image) {
                      if (image.data == null) {
                        return const SizedBox.shrink();
                      }
                      return ImageListTile(
                        image: image,
                        deleteIcon: false,
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

  _showModerationDialog(BuildContext context, QueueStatus status) {
    var controller = context.read<ModerateQueueController>();
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
