import 'package:carousel_slider/carousel_slider.dart';
import 'package:ddnuvem/models/animation.dart' as model;
import 'package:ddnuvem/utils/widgets/loading_widget.dart';
import 'package:ddnuvem/views/queues/controllers/external_queue_view_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../models/external_queue.dart';

class ExternalQueueViewPage extends StatefulWidget {
  const ExternalQueueViewPage({super.key, this.queue});

  final ExternalQueue? queue;

  @override
  State<ExternalQueueViewPage> createState() => _QueueViewPageState();
}

class _QueueViewPageState extends State<ExternalQueueViewPage> {
  bool loading = false;
  bool isConnected = true;
  late model.Animation animation;

  @override
  Widget build(BuildContext context) {
    try {
      final queueViewController = context.watch<ExternalQueueViewController>();
      loading = queueViewController.loadingImages;
      animation = queueViewController.animation;
      isConnected = queueViewController.isConnected;
    } catch (e) {
      loading = false;
      isConnected = true;
    }

    if (loading || widget.queue == null) {
      return loadingWidget(context);
    }

    return Focus(
        child: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: widget.queue!.duration),
                enlargeCenterPage: animation.enlargeCenter,
                reverse: animation.reverse,
                enlargeStrategy: animation.enlargeStrategy,
                enlargeFactor: animation.enlargeFactor,
                autoPlayCurve:  animation.animationCurve,
                scrollDirection: animation.scrollDirection,
                autoPlayAnimationDuration: Duration(milliseconds: animation.durationMilliseconds),
              ),
              items: widget.queue!.images.map((image) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: image.data != null
                      ? Image.memory(
                    image.data!,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey,
                  ),
                );
              }).toList(),
            ),
            if (!isConnected)
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 20.0),
                    ],
                  ),
                ),
              ),
          ],
        )
      );
    }
}
