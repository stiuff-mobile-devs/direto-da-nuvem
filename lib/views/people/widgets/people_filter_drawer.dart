import 'package:ddnuvem/views/people/people_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeopleFilterDrawer extends StatelessWidget {
  const PeopleFilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: eventualmente substituir esses hardcodeds
    List<String> userPrivileges = ["Superadmin", "Admin", "Instalador"];

    return Column(children: [
      const SizedBox(height: 16),
      const Text(
        "Filtrar por papel",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Expanded(
          child: ListView.builder(
        itemCount: userPrivileges.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(userPrivileges[index]),
            onTap: () {
              context
                  .read<PeopleFilterController>()
                  .addFilter(userPrivileges[index]);
              /* TODO: será que não é melhor deixar o usuário aplicar
              todos os filtros e só depois fechar quando quiser? */
              Navigator.pop(context);
            },
          );
        },
      ))
    ]);
  }
}
