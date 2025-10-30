import 'package:carousel_slider/carousel_slider.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/models/animation.dart' as model;
import 'package:ddnuvem/utils/widgets/loading_widget.dart';
import 'package:flutter/services.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:ddnuvem/views/queues/controllers/queue_view_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class QueueViewPage extends StatefulWidget {
  const QueueViewPage({super.key, this.queue});

  final Queue? queue;

  @override
  State<QueueViewPage> createState() => _QueueViewPageState();
}

class _QueueViewPageState extends State<QueueViewPage> {
  bool showView = true;
  bool loading = false;
  bool registered = true;
  late model.Animation animation;

  @override
  Widget build(BuildContext context) {
    try {
      final queueViewController = context.read<QueueViewController>();
      loading = queueViewController.loadingImages;
      registered = queueViewController.registeredDevice;
      animation = queueViewController.animation;
    } catch (e) {
      loading = false;
      registered = true;
    }

    if (loading || widget.queue == null) {
      return loadingWidget(context);
    }

    if (showView) {
      return Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter)) {
            if (!registered) {
              _unregisteredDeviceDialog();
            } else {
              setState(() {
                showView = false;
              });
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector (
          onTap: () {
            if (!registered) {
              _unregisteredDeviceDialog();
            } else {
              setState(() {
                showView = false;
              });
            }
          },
          child: CarouselSlider(
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
          )
        )
      );
    } else {
      return _registeredDeviceDialog();
    }
  }

  _registeredDeviceDialog() {
    final admin = context.read<UserController>().isCurrentUserAdmin();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              showView = true;
            });
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 40)
          ),
          child: const Text("Play", style: TextStyle(
              color: AppTheme.primaryBlue)),
        ),
        !admin ?
        ElevatedButton(
          onPressed: () {
            context.read<UserController>().logout();
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 40)
          ),
          child: const Text("Sair", style: TextStyle(
              color: AppTheme.primaryBlue)),
        ) :
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(90, 40)
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Voltar", style: TextStyle(
              color: AppTheme.primaryBlue)),
        ),
      ],
    );
  }

  _unregisteredDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: SvgPicture.asset(
                  height: 120,
                  'assets/DiretoDaNuvem-JustLogo.svg',
                  semanticsLabel: 'Logo Direto da Nuvem'
              ),
            ),
            const SizedBox(height: 25),
            const Text("Seja bem vindo ao Direto da Nuvem!\nParece que o seu dispositivo não está cadastrado.\nSe está prestes a cadastrá-lo, certifique-se de que a sua conta é instaladora.\nCaso esse dispositivo já esteja cadastrado, entre em contato com o nosso suporte."),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 40),
                maximumSize: const Size(160, 40),
                backgroundColor: AppTheme.primaryBlue
              ),
              child: const Text("Tocar fila", style: TextStyle(
                  color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<UserController>().logout();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 40),
                maximumSize: const Size(160, 40),
                backgroundColor: AppTheme.primaryBlue
              ),
              child: const Text("Sair", style: TextStyle(
                  color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
