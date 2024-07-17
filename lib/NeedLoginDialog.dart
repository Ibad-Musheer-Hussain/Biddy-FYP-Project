import 'package:flutter/material.dart';

class NeedLogin extends StatefulWidget {
  @override
  _NeedLoginState createState() => _NeedLoginState();
}

class _NeedLoginState extends State<NeedLogin> {
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 255, 218, 223),
      title: Center(
        child: Icon(
          Icons.info_outline_rounded,
          size: 80,
        ),
      ),
      content: Text(
          "You need to login to access this feature. Please log in or sign up to continue."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black38),
            )),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/LoginPage');
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.pink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text('Continue'),
        )
      ],
    );
  }
}
