import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/image_ui.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final storage = FirebaseStorage.instance;
  late DeviceController deviceController;
  late UserController userController;
  late DiretoDaNuvemAPI diretoDaNuvemAPI;

  bool playing = false;
  bool isLoading = true;

  List<ImageUI> images = [];

  String? selectedImageId;
  Map<String, bool> showX = {};

  @override
  initState() {
    super.initState();
    getDependencies();
    getCurrentQueue();
  }

  getDependencies() {
    userController = Provider.of<UserController>(context, listen: false);
    deviceController = Provider.of<DeviceController>(context, listen: false);
    diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen: false);
  }

  getCurrentQueue() async {
    setState(() {
      images = [];
      isLoading = true;
    });
    await deviceController.fetchGroupAndQueue();
    for (var imagePath in deviceController.currentQueue!.images) {
      var a = await storage.ref().child(imagePath.path).getData();
      images.add(ImageUI(path: imagePath.path, data: a!));
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildThumbnail(ImageUI image) {
    return Stack(
      key: Key(image.path),
      alignment: Alignment.topRight,
      children: [
        Container(
          width: 150,
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selectedImageId == image.path) {
                  selectedImageId = null;
                  showX[image.path] = false;
                } else {
                  showX[selectedImageId ?? ''] = false;
                  selectedImageId = image.path;
                  showX[image.path] = true;
                }
              });
            },
            child: Image.memory(
              image.data!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showX.containsKey(image.path) &&
            showX[image.path]! &&
            selectedImageId == image.path)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _deleteImage(image.path),
          ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ImageUI item = images.removeAt(oldIndex);
      images.insert(newIndex, item);
    });
    _saveNewOrderToFirebase();
  }

  Future<void> _saveNewOrderToFirebase() async {
    // await diretoDaNuvemAPI.queueResource.updateImageList(
    //     deviceController.currentQueue!.id, images.map((e) => e.path).toList());

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Nova ordem salva!')));
  }

  Future<void> _deleteImage(String imagePath) async {
    setState(
      () {
        images.removeWhere((element) => element.path == imagePath);
      },
    );
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
                // diretoDaNuvemAPI.queueResource.updateImageList(
                //     deviceController.currentQueue!.id,
                //     images.map((e) => e.path).toList());
                // await storage.ref().child(imagePath).delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Imagem removida!')),
                );
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
    // Pick an image
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    final Uint8List imageBytes = await pickedFile.readAsBytes();

    final storageRef = FirebaseStorage.instance.ref().child(pickedFile.name);
    await storageRef.putData(imageBytes);

    // diretoDaNuvemAPI.queueResource.update(
    //     deviceController.currentQueue!.id,
    //     [...images.map((e) => e.path), pickedFile.name]);

    await getCurrentQueue();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagem salva!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : playing
                ? showQueue(context)
                : showMenu(context));
  }

  SafeArea showMenu(BuildContext context) {
    return SafeArea(
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
                children: images.map(_buildThumbnail).toList(),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
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
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, RoutePaths.groupCreate);
                        }, child: const Text("Criar grupo")),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector showQueue(BuildContext context) {
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
          autoPlayInterval: const Duration(seconds: 7),
          enlargeCenterPage: true,
        ),
        items: images.map((image) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Image.memory(
                  image.data!,
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
