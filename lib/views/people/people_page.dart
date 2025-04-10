import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(child: Scaffold(
          appBar: AppBar(
            title: const Text("Pessoas"),
          ),
          body: Consumer<GroupController>(
            builder: (context, controller, _) {
              return ListView(
                children: [
                  ...controller.groups.map((e) => Text(e.description))
                ],
              );
            }
          )
        )),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(onPressed: () {}, 
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white,),
          ),
        )
      ],
    );
  }
}