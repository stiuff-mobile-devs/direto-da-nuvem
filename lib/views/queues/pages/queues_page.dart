import 'package:ddnuvem/controllers/external_queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/connection_service.dart';
import 'package:ddnuvem/utils/widgets/custom_snackbar.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/pages/queue_create_update_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/external_queue.dart';
import '../widgets/external_queue_card.dart';

class QueuesPage extends StatelessWidget {
  const QueuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ExternalQueueController, UserController, ConnectionService>(
      builder: (context, queueController, userController, connection, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Minhas Filas"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _pushCreateQueuePage(context);
            },
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<ExternalQueueController>(
              builder: (context, queueController, _) {
                return ListView(
                  padding: const EdgeInsets.only(bottom: 70),
                  children: [
                    Text(
                      "Fila ativa",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    queueCardForActiveQueue(context),
                    const SizedBox(height: 8),
                    Text(
                      "Outras filas",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    otherQueuesList(context),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget queueCardForActiveQueue(BuildContext context) {
    final controller = context.read<ExternalQueueController>();
    ExternalQueue? queue;

    for (var q in controller.queues) {
      if (q.id == controller.activeQueueId) {
        queue = q;
      }
    }
    if (queue == null) {
      return const Text("Nenhuma fila ativa");
    }
    return ExternalQueueCard(
      queue: queue,
      isActive: true,
    );
  }

  Widget otherQueuesList(BuildContext context) {
    final queueController = context.read<ExternalQueueController>();

    final otherQueues = queueController
        .otherQueuesList()
        .map((e) => ExternalQueueCard(queue: e));

    return Column(
      children: otherQueues.toList(),
    );
  }

  _pushCreateQueuePage(BuildContext context) {
    final queueController = context.read<ExternalQueueController>();
    final snackBar = CustomSnackbar(context);
    String text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QueueCreateUpdatePage(
          queue: Queue.empty(),
          onSave: (queue) async {
            try {
              ExternalQueue newQueue = ExternalQueue.fromQueue(queue);
              await queueController.createQueue(newQueue);
              text = "Fila criada com sucesso!";
            } catch (e) {
              text = e.toString();
            }
            snackBar.buildMessage(text);
          },
        ),
      ),
    );
  }
}
