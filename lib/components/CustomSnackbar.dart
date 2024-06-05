// ignore_for_file: file_names

import 'package:flutter/material.dart';

SnackBar buildCustomSnackBar({
  required BuildContext context,
  required String message,
  Color? backgroundColor,
  bool showCloseIcon = true,
  Duration duration = const Duration(seconds: 2),
}) {
  return SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: backgroundColor ?? Colors.pink,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    duration: duration,
    action: showCloseIcon
        ? SnackBarAction(
            label: 'X',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
        : null,
  );
}
