import 'package:carousel_slider/carousel_slider.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:flutter/material.dart';

class QueueViewPage extends StatelessWidget {
  const QueueViewPage({super.key, required this.queue});

  final Queue queue;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(milliseconds: 10000),
        enlargeCenterPage: true,
      ),
      items: queue.images.map((image) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: image.data != null ? Image.memory(
            image.data!,
            fit: BoxFit.cover,
          ) : Container(
            color: Colors.grey,
          ),
        );
      }).toList(),
    );
  }
}
