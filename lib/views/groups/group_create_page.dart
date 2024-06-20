import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late DiretoDaNuvemAPI _diretoDaNuvemAPI;

  getDependencies() {
    _diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen:false);
  }

  @override
  void initState() {
    getDependencies();
    super.initState();
  }

  String? id;
  String? name;
  String? description;
  String? currentQueue;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String>? admins;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criação de Fila")),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Nome',
              ),
              onSaved: (String? value) {
                  name = value;
              }
              ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Descrição',
              ),
                onSaved: (String? value) {
                  description = value;
                }
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Admins',
              ),
                onSaved: (String? value) {
                  admins = value as List<String>?;
                }
            ),
            DropdownButton(items: List.from(Firestore.collection('queues').where('name' isEqualTo: name).get()), onChanged: currentQueue = this.queues),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Salvando...')));
                    _formKey.currentState!.save();
                    await postGroup(name!, description!, id!, currentQueue!, createdAt!, updatedAt!, admins!,);
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      )
    );


  }
  postGroup(String name, String id, String description, String currentQueue, DateTime createdAt, DateTime updatedAt, List<String> admins,) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    DateTime createdAt = DateTime.now(); //needs to only work for the first timme executed per group
    DateTime updatedAt = DateTime.now();
    final ref = storage.ref().child(name); // criando referência


    Map<String, dynamic> group = {
      "name": name,
      "description": description,
      "currentQueue": currentQueue,
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt
    };

    await db.collection("groups").doc(name).set(group); // criando grupo
  }

}

