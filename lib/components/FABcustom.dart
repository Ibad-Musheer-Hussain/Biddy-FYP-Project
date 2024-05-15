// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FABcustom extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const FABcustom({super.key, required this.onTap(), required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.pink,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
          ),
        ),
      ),
    );
  }
}
