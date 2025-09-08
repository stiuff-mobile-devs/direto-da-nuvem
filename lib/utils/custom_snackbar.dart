import 'package:ddnuvem/utils/theme.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  BuildContext context;
  String? message;
  Color? color;

  CustomSnackbar(this.context);

  buildType(String str, String type) {
    color = _getColor(type);
    message = str;
    return _build();
  }

  buildMessage(String str) {
    final regex = RegExp(r'^(Exception: |Error: )');
    if (str.contains(regex)) {
      message = str.replaceAll(regex, "");
      color = AppTheme.primaryRed;
    } else {
      message = str;
      color = Colors.green;
    }
    return _build();
  }

  _build() {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: color,
        content: Container(
          height: 20,
          alignment: Alignment.center,
          child: Text(message!, style: const TextStyle(color: Colors.white,
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


