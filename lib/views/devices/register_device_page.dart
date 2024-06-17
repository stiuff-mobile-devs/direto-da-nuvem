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
  String? groupId;
  String? description;
  String? locale;

  getDependencies() {
    _diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen: false);
  }

  listGroups() async {
    List<Group> gro = await _diretoDaNuvemAPI.groupResource.listAll();
    setState(() {
      groups = gro;
    });
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
      description: description!,
      groupId: groupId!,
      locale: locale!,
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

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return "Valor não pode ser nulo";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                validator: validate,
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                decoration: const InputDecoration(hintText: "Descrição"),
              ),
              TextFormField(
                validator: validate,
                onChanged: (value) {
                  setState(() {
                    locale = value;
                  });
                },
                decoration: const InputDecoration(hintText: "Localização"),
              ),
              choseGroup(),
              submitButton(),
            ],
          )),
    ));
  }

  Widget submitButton() {
    return ElevatedButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          registerDevice();
        },
        child: const Text("Registrar"));
  }

  Widget choseGroup() {
    List<DropdownMenuEntry<String>> entries = groups.map(
      (e) {
        return DropdownMenuEntry<String>(value: e.id!, label: e.name);
      },
    ).toList();

    return DropdownMenu<String>(
      dropdownMenuEntries: entries,
      onSelected: (String? id) {
        setState(() {
          groupId = id;
        });
      },
      label: const Text("Selectionar Grupo"),
    );
  }
}
