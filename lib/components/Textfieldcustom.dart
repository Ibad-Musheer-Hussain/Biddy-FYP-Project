// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';

class TextfieldCustom extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool obscureText;
  const TextfieldCustom(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.white, fontSize: 16),
      controller: textEditingController,
      obscureText: obscureText,
      decoration: InputDecoration(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          fillColor: Colors.grey,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white)),
    );
  }
}
