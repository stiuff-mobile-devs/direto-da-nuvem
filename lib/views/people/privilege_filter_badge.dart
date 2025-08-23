import 'package:ddnuvem/utils/theme.dart';
import 'package:flutter/material.dart';

class PrivilegeFilterBadge extends StatelessWidget {
  const PrivilegeFilterBadge(
      {super.key,
      required this.filter,
      required this.onAdd,
      required this.onRemove});

  final String filter;
  final Function(String filter) onAdd;
  final Function(String filter) onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
            decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                    onTap: () => onRemove(filter),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(filter,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                        const Icon(Icons.close, size: 16, color: Colors.white)
                      ],
                    )))));
  }
}
