// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp2> {
  late Timer _timer;
  int _secondsRemaining = 12000000;

  @override
  void initState() {
    super.initState();

    // Start the countdown timer
    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_secondsRemaining == 0) {
          // Countdown is complete, stop the timer
          timer.cancel();
        } else {
          // Update the countdown timer
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the remaining time as HH:MM:SS
    // Calculate days, hours, minutes, and seconds
    int days = _secondsRemaining ~/ (3600 * 24);
    int hours = (_secondsRemaining % (3600 * 24)) ~/ 3600;
    int minutes = (_secondsRemaining % 3600) ~/ 60;
    int seconds = _secondsRemaining % 60;

    // Format the remaining time as DD:HH:MM:SS
    String formattedTime = '${days.toString().padLeft(2, '0')}:'
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Countdown Timer Example'),
        ),
        body: Center(
          child: Text(
            formattedTime,
            style: TextStyle(fontSize: 24.0),
          ),
        ),
      ),
    );
  }
}
