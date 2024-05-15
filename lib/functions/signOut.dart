// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, prefer_const_constructors

import 'package:biddy/Signing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    // Successfully signed out
    print('User signed out');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  } catch (e) {
    print('Error signing out: $e');
  }
}
