import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
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
  late DeviceController _deviceController;
  late UserController _userController;

  List<Group> groups = [];
  String? deviceId;
  String? groupId;
  String? description;
  String? locale;

  getDependencies() {
    _diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen: false);
    _userController = Provider.of<UserController>(context, listen: false);
    _deviceController = Provider.of<DeviceController>(context, listen: false);
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
      registeredBy: _userController.uid!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description!,
      groupId: groupId!,
      locale: locale!,
    );
    _deviceController.register(device);
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastro de novo dispositivo",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height:12,),
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
              const SizedBox(height:12,),
              choseGroup(),
              const SizedBox(height: 12,),
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
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text("Registrar"));
  }

  Widget choseGroup() {
    List<DropdownMenuEntry<String>> entries = groups.map(
      (e) {
        return DropdownMenuEntry<String>(value: e.id!, label: e.name);
      },
    ).toList();

    return DropdownMenu<String>(
      width: 250,
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
