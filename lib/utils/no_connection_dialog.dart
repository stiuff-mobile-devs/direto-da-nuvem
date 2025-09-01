import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

AwesomeDialog noConnectionDialog(BuildContext context) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.scale,
    title: 'Desconectado',
    desc: 'Você precisa de conexão à Internet para realizar esta ação.',
  );
}