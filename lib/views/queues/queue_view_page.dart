import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueueViewPage extends StatefulWidget {
  const QueueViewPage({super.key});

  @override
  State<QueueViewPage> createState() => _QueueViewPageState();
}

class _QueueViewPageState extends State<QueueViewPage> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late UserController userController;
  late DiretoDaNuvemAPI diretoDaNuvemAPI;
  late DeviceController deviceController;

  bool playing = true;
  bool isLoading = true;
  List<Map<String, dynamic>> uniqueQueue = [];
  List<Uint8List> imagesData = [];

  @override
  initState() {
    super.initState();
    getDependencies();
    getCurrentQueue();
  }

  getCurrentQueue() async {
    setState(() {
      isLoading = true;
    });
    await deviceController.fetchGroupAndQueue();
    for (var imagePath in deviceController.currentQueue!.images) {
      var a = await storage.ref().child(imagePath).getData();
      imagesData.add(a!);
    }
    setState(() {
      isLoading = false;
    });
  }

  getDependencies() {
    userController = Provider.of<UserController>(context, listen: false);
    diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen: false);
    deviceController = Provider.of<DeviceController>(context, listen: false);
  }

  Future<void> getUniqueQueue() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> queue = [];
      await db.collection("unique_queue").get().then((querySnapshot) async {
        final docs = querySnapshot.docs;
        for (var index = 0; index < docs.length; index++) {
          final docSnapshot = docs[index];

          Map<String, dynamic> image = {};

          image["id"] = docSnapshot.data()["id"];
          image["name"] = docSnapshot.data()["name"];
          image["position"] = docSnapshot.data()["position"];
          image["image"] =
              await storage.ref().child(docSnapshot.data()["id"]).getData();

          queue.add(image);
        }
      }, onError: (e) {
        debugPrint("Error completing: $e");
      });
      this.uniqueQueue = queue;

      queue.sort(
          (a, b) => (a["position"] as int).compareTo(b["position"] as int));

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERRO db.collection("movies").get(): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : playing
                ? queueViewWidget(context)
                : homeWidget());
  }

  Center homeWidget() {
    return Center(
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    playing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text("Tocar Fila"),
              ),
            ),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  getCurrentQueue();
                  setState(() {
                    playing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text("Atualizar"),
              ),
            ),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: userController.logout,
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text("Sair"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector queueViewWidget(BuildContext context) {
    Queue currentQueue = deviceController.currentQueue!;
    return GestureDetector(
      onTap: () {
        setState(() {
          playing = false;
        });
      },
      child: CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          viewportFraction: 1.0,
          autoPlay: true,
          autoPlayInterval: Duration(milliseconds: currentQueue.duration),
          enlargeCenterPage: true,
        ),
        items: imagesData.map((image) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Image.memory(
                  image,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
