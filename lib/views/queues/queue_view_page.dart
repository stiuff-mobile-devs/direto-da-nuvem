import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class QueueViewPage extends StatefulWidget {
  const QueueViewPage({super.key});

  @override
  State<QueueViewPage> createState() => _QueueViewPageState();
}

class _QueueViewPageState extends State<QueueViewPage> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  bool playing = true;
  bool isLoading = true;
  List<Map<String, dynamic>> queue = [];

  @override
  initState() {
    super.initState();
    getUniqueQueue();
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
      debugPrint("Queue: $queue");
      this.queue = queue;

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
            child: PageView(
              children: queue.map((image) {
                return Image.memory(
                  image["image"],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }).toList(),
            ),
          )
          : Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  playing = true;
                });
              },
              child: const Text("Play")),
          )
    );
  }
}