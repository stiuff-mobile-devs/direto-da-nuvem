import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {

  late DiretoDaNuvemAPI _diretoDaNuvemAPI;

  getDependencies() {
    _diretoDaNuvemAPI = Provider.of<DiretoDaNuvemAPI>(context, listen:false);
  }

  @override
  void initState() {
    getDependencies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Center(child: Text("TODO: GroupCreatePage"),),
    );
  }
}