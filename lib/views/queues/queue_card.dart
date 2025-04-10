import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/routes/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueCard extends StatelessWidget {
  const QueueCard({super.key, required this.queue});

  final Queue queue;

  @override
  Widget build(BuildContext context) {
    String numberOfPhotos = queue.images.length == 1 
        ? "${queue.images.length} foto"
        : "${queue.images.length} fotos";
    QueueController queueController = Provider.of(context, listen: false);
    return Card(
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
                if (!queue.updated) const Padding(
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
            IconButton(onPressed: () {
              queueController.selectQueue(queue);
              Navigator.of(context).pushNamed(
                RoutePaths.queueEdit,
              );
            }, icon: const Icon(Icons.edit)),
          ],
        ),
      ),
    );
  }
}
