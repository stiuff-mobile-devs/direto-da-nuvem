import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/queue.dart';

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
  String selectedQueueId = "";
  List<Queue> queues = [];
  List<String> queueIds = [];


  getDependencies() {
    _diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen:false);
    listQueues();
  }

  listQueues() async {
    queues = await _diretoDaNuvemAPI.queueResource.listAll();
    queueIds = getQueueIds(queues);
    selectedQueueId = queueIds[0];
    setState(() {});
  }

  List<String> getQueueIds(List<Queue> queues) {
    return queues.map((queue) => queue.id).toList();
  }

  @override
  void initState()  {
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

            DropdownButton<String>(
              value: selectedQueueId,
              hint: Text('Select Queue ID'), // Placeholder text
              items: queueIds.map<DropdownMenuItem<String>>((String id) {
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(id),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedQueueId = value!;
                });
                print("Selected Queue ID: $value"); // Print the selected ID
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Criando Grupo')));
                    _formKey.currentState!.save();
                    await postGroup(
                      name!,
                      description!,
                      id!,
                      currentQueue!,
                      createdAt!,
                      updatedAt!,
                      admins!,
                    );
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Criar Grupo'),
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

