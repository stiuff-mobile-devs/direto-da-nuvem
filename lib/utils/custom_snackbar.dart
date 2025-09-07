import 'package:ddnuvem/utils/theme.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  BuildContext context;
  CustomSnackbar(this.context);

  build(String text, String type) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: _getColor(type),
        content: Container(
          height: 20,
          alignment: Alignment.center,
          child: Text(text, style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Color _getColor(String type) {
    final Map<String, Color> typeColors = {
      "error": AppTheme.primaryRed,
      "success": Colors.green,
    };

    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }
}


