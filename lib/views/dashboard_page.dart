import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/routes/route_paths.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'groups/group_create_page.dart';

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

  String? selectedImageId;
  Map<String, bool> showX = {};

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
    return Stack(
      key: Key(image["id"]),
      alignment: Alignment.topRight,
      children: [
        Container(
          width: 150,
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selectedImageId == image["id"]) {
                  selectedImageId = null;
                  showX[image["id"]] = false;
                } else {
                  showX[selectedImageId ?? ''] = false;
                  selectedImageId = image["id"];
                  showX[image["id"]] = true;
                }
              });
            },
            child: Image.memory(
              image["image"],
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showX.containsKey(image["id"]) && showX[image["id"]]! && selectedImageId == image["id"])
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _deleteImage(image["id"]),
          ),
      ],
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
    _saveNewOrderToFirebase();
  }

  Future<void> _saveNewOrderToFirebase() async {
    try {
      for (int i = 0; i < queue.length; i++) {
        await db.collection("unique_queue").doc(queue[i]["id"]).update({
          "position": i,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nova ordem salva!')),
      );
    } catch (e) {
      debugPrint('Error saving new order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar a nova ordem.')),
      );
    }
  }

  Future<void> _deleteImage(String imageId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text("Tem certeza que deseja excluir esta imagem?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await db.collection("unique_queue").doc(imageId).delete();
                  setState(() {
                    queue.removeWhere((image) => image["id"] == imageId);
                  });
                  await storage.ref().child(imageId).delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imagem removida!')),
                  );
                } catch (e) {
                  debugPrint('Error deleting image: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao remover a imagem.')),
                  );
                }
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      // Pick an image
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      String imageId = DateTime.now().millisecondsSinceEpoch.toString();

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();

        final storageRef = FirebaseStorage.instance.ref().child(imageId);

        await storageRef.putData(imageBytes);

        int nextPosition = queue.length;

        await db.collection('unique_queue').doc(imageId).set({
          'id': imageId,
          'name': pickedFile.name,
          'position': nextPosition,
        });

        await getUniqueQueue();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem salva!')),
        );
      }
    } catch (e) {
      debugPrint('Error picking and saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar a imagem.')),
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
        : SafeArea(
          child: Container(
            color: Colors.blueGrey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    onReorder: _onReorder,
                    children: queue.map((image) => _buildThumbnail(image)).toList(),
                  ),
                ),
                const SizedBox(height: 24,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
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
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: _pickAndSaveImage,
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text("Nova Imagem"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
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
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RoutePaths.group);
                          },
                          child: const Text("Criar"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}