import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'people_filter_controller.dart';

class PeopleSearchBar extends StatefulWidget {
  const PeopleSearchBar({super.key});

  @override
  State<PeopleSearchBar> createState() => _PeopleSearchBarState();
}

class _PeopleSearchBarState extends State<PeopleSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = context.read<PeopleFilterController>().searchQuery;
    _controller = TextEditingController(text: initial);
    _controller.addListener(() {
      final filter = context.read<PeopleFilterController>();
      final value = _controller.text;
      if (filter.searchQuery != value) {
        filter.updateSearch(value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          return TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou e-mail',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        context.read<PeopleFilterController>().clearSearch();
                      },
                    ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          );
        },
      ),
    );
  }
}