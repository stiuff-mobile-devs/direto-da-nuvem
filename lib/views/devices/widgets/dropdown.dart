import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvDropdown extends StatefulWidget {
  final String? selected;
  final List<String> options;
  final void Function(String) onSelected;
  final FocusNode focusNode;
  final String label;

  const TvDropdown({
    super.key,
    required this.selected,
    required this.options,
    required this.onSelected,
    required this.focusNode,
    required this.label,
  });

  @override
  State<TvDropdown> createState() => _TvDropdownState();
}

class _TvDropdownState extends State<TvDropdown> {
  bool _open = false;

  void _toggleDropdown() {
    setState(() {
      _open = !_open;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _toggleDropdown();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: _toggleDropdown,
            child: Text(widget.selected ?? widget.label),
          ),
          if (_open)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.options.map((option) {
                return Focus(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelected(option);
                      setState(() {
                        _open = false;
                      });
                    },
                    child: Text(option),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
