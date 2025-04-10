import 'package:ddnuvem/models/image_ui.dart';
import 'package:ddnuvem/views/queues/queue_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageListTile extends StatelessWidget {
  const ImageListTile({super.key, required this.image});

  final ImageUI image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: double.infinity, maxHeight: 300),
            child: image.loading
                ? const CircularProgressIndicator()
                : Image.memory(
                    image.data!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
            top: -8,
            right: -8,
            child: IconButton.filled(
                onPressed: () {
                  context.read<QueueEditController>().removeQueueImage(image);
                },
                icon: const Icon(Icons.close)))
      ],
    );
  }
}
