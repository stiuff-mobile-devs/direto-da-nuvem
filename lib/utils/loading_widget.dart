import 'package:ddnuvem/utils/theme.dart';
import 'package:flutter/material.dart';

Widget loadingWidget(BuildContext context) {
  return Container(
    color: Theme.of(context).colorScheme.surface,
    child: const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
      ),
    ),
  );
}