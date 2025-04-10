import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageViewPage extends StatelessWidget {
  final Uint8List imageData;

  const ImageViewPage({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer'),
      ),
      body: Center(
        child: imageData.isNotEmpty
            ? Image.memory(imageData)
            : const Text('No image data available'),
      ),
    );
  }
}