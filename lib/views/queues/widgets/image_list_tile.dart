import 'package:ddnuvem/models/image.dart' as image_model;
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/controllers/queue_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageListTile extends StatelessWidget {
  const ImageListTile({super.key, required this.image, this.deleteIcon = true});

  final image_model.Image image;
  final bool deleteIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: double.infinity, maxHeight: 300),
            child: Image.memory(
                image.data!,
                fit: BoxFit.cover,
                key: key,
              )
          ),
        ),
        if (deleteIcon) ...[
          Positioned(
            top: -8,
            right: -8,
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
              ),
              onPressed: () {
                context.read<QueueEditController>().removeQueueImage(image);
              },
              icon: const Icon(Icons.close)
            )
          )
        ]
      ],
    );
  }
}
