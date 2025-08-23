import 'package:ddnuvem/models/group.dart';
import 'package:ddnuvem/utils/theme.dart' show AppTheme;
import 'package:flutter/material.dart';

class FilterBadge extends StatelessWidget {
  const FilterBadge({
    super.key,
    required this.filter,
    required this.onAdd,
    required this.onRemove,
  });

  final Group filter;
  final Function(Group filter) onRemove;
  final Function(Group filter) onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () => onRemove(filter),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(filter.name, style: const TextStyle(fontSize: 16,color: Colors.white),),
                const Icon(Icons.close,size: 16, color: Colors.white,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
