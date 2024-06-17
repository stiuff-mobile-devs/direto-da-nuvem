import 'package:ddnuvem/models/device.dart';
import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterDevicePage extends StatefulWidget {
  const RegisterDevicePage({super.key});

  @override
  State<RegisterDevicePage> createState() => _RegisterDevicePageState();
}

class _RegisterDevicePageState extends State<RegisterDevicePage> {
  final _formKey = GlobalKey<FormState>();
  late DiretoDaNuvemAPI _diretoDaNuvemAPI;

  List<Group> groups = [];
  String? deviceId;

  getDependencies() {
    _diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen: false);
  }

  listGroups() async {
    groups = await _diretoDaNuvemAPI.groupResource.listAll();
    setState(() {});
  }

  getId() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var androidInfo = await deviceInfoPlugin.androidInfo;
    setState(() {
      deviceId = androidInfo.id;
    });
  }

  registerDevice() async {
    Device device = Device(
      id: deviceId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: "",
      groupId: "",
      locale: "",
    );
    bool created = await _diretoDaNuvemAPI.deviceResource.create(device);

    if (created) {
      debugPrint("dispositivo $deviceId criado com sucesso!");
    }
  }

  @override
  void initState() {
    getDependencies();
    listGroups();
    getId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Register Device Page
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: "Descrição"),
                ),
              ],
            )));
  }

  Widget choseGroup() {
    List<DropdownMenuEntry> entries = groups.map((e) {
      return DropdownMenuEntry(value: e.id, label: e.name);
    },).toList();

    return DropdownMenu(
      dropdownMenuEntries: entries,
      label: const Text("Selectionar Grupo"),
    );
  }
}
