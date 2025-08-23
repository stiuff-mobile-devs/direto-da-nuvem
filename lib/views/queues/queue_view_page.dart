import 'package:carousel_slider/carousel_slider.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class QueueViewPage extends StatefulWidget {
  const QueueViewPage({super.key, required this.queue});

  final Queue queue;

  @override
  State<QueueViewPage> createState() => _QueueViewPageState();
}

class _QueueViewPageState extends State<QueueViewPage> {
  bool showView = true;

  @override
  Widget build(BuildContext context) {
    UserController userController = context.read<UserController>();
    final admin = userController.currentUser!.privileges.isAdmin
        || userController.currentUser!.privileges.isSuperAdmin;

    if (showView) {
      return GestureDetector (
        onTap: () {
          setState(() {
           showView = false;
         });
        },
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(milliseconds: 10000),
            enlargeCenterPage: true,
          ),
          items: widget.queue.images.map((image) {
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
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showView = true;
              });
            },
            child: const Text("Play", style: TextStyle(
                color: AppTheme.primaryBlue)),
          ),
          !admin ?
          ElevatedButton(
            onPressed: () {
              context.read<UserController>().logout();
            },
            child: const Text("Sair", style: TextStyle(
                color: AppTheme.primaryBlue)),
          ) :
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Voltar", style: TextStyle(
                color: AppTheme.primaryBlue)),
          ),
        ],
      );
    }
  }
}
