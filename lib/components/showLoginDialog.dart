import 'package:biddy/NeedLoginDialog.dart';
import 'package:flutter/material.dart';

void showLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return NeedLogin();
    },
  );
}
