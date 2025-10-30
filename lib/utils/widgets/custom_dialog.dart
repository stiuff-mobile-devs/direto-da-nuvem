import 'package:flutter/material.dart';

customDialog(BuildContext context, String title, String desc, Widget actions) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Text(desc,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [actions],
      );
    },
  );
}