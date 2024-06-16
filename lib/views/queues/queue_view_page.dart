import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
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

  bool playing = true;
  bool isLoading = true;
  List<Map<String, dynamic>> queue = [];

  @override
  initState() {
    super.initState();
    getUniqueQueue();
    getDependencies();
  }

  getDependencies() {
    userController =
        Provider.of<UserController>(context, listen: false);
  }

  Future<void>getUniqueQueue() async {
    try{
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
          image["image"] = await storage.ref().child(docSnapshot.data()["id"]).getData();

          queue.add(image);
        }
      }, onError: (e) {
        debugPrint("Error completing: $e");
      });
      this.queue = queue;

      queue.sort((a, b) => (a["position"] as int).compareTo(b["position"] as int));

      setState(() {
        isLoading = false;
      });
    } catch(e) {
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
          ? GestureDetector(
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
                autoPlayInterval: const Duration(seconds: 7),
                enlargeCenterPage: true,
              ),
              items: queue.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.memory(
                        image["image"],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          )
          : Center(
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
                  child: const Text("Tocar Fila"),
                ),
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    getUniqueQueue();
                    setState(() {
                      playing = true;
                    });
                  },
                  child: const Text("Atualizar"),
                ),
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: userController.logout,
                  child: const Text("Sair"),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}