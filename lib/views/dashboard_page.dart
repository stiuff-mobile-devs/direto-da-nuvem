import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late UserController userController;

  bool playing = false;
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

  Widget _buildThumbnail(Map<String, dynamic> image) {
    return Container(
      key: ValueKey(image["id"]), // Important for ReorderableListView
      width: 150,
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Image.memory(
        image["image"],
        fit: BoxFit.cover,
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Map<String, dynamic> item = queue.removeAt(oldIndex);
      queue.insert(newIndex, item);
    });
  }

  Future<void> _saveNewOrderToFirebase() async {
    try {
      for (int i = 0; i < queue.length; i++) {
        await db.collection("unique_queue").doc(queue[i]["id"]).update({
          "position": i,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fila salva!')),
      );
    } catch (e) {
      debugPrint('Error saving new order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar a nova ordem.')),
      );
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
              autoPlayInterval: const Duration(seconds: 5),
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
        : SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    onReorder: _onReorder,
                    children: queue.map((image) => _buildThumbnail(image)).toList(),
                  ),
                ),
                const SizedBox(height: 24,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          _saveNewOrderToFirebase();
                        },
                        child: const Text("Salvar"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            playing = true;
                          });
                        },
                        child: const Text("Tocar Fila"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: userController.logout,
                        child: const Text("Sair"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }
}