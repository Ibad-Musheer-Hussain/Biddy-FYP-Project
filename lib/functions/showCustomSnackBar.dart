// ignore_for_file: file_names

import 'package:biddy/components/CustomSnackbar.dart';
import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    buildCustomSnackBar(
      context: context,
      message: message,
    ),
  );
}
