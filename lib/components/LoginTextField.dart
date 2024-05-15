// ignore_for_file: file_names

import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool obscureText;
  const LoginTextField(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: textEditingController,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: const TextStyle(
            color: Colors.black, // Customize label text color
            fontSize: 18.0, // Customize label font size
            //fontWeight: FontWeight.bold, // Customize label font weight
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.pink, // Change the focused color as needed
              width: 3.0, // Change the focused line width as needed
            ),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.pink, // Change the unfocused color as needed
              width: 2.0, // Change the unfocused line width as needed
            ),
          ),
        ),
      ),
    );
  }
}
