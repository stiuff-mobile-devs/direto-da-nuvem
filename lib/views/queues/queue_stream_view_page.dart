import 'package:carousel_slider/carousel_slider.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/views/queues/queue_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueStreamViewPage extends StatelessWidget {
  const QueueStreamViewPage({super.key, required this.queue});

  final Stream<Queue?> queue;

  @override
  Widget build(BuildContext context) {
    context.watch<QueueViewController>();
    return StreamBuilder(
      stream: queue,
      builder: (context, queueSnapshot) {
        if (queueSnapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Consumer<QueueViewController>(
          builder: (context, _,a) {
            return CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(milliseconds: 10000),
                enlargeCenterPage: true,
              ),
              items: queueSnapshot.data!.images.map((image) {
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
        );
      }
    );
  }
}
