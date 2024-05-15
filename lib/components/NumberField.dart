// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool obscureText;

  const NumberField({
    Key? key,
    required this.textEditingController,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: widget.textEditingController,
        obscureText: widget.obscureText,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: widget.hintText,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.pink,
              width: 3.0,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.pink,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
