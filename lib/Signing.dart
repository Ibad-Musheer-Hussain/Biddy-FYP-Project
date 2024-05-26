// ignore_for_file: file_names, prefer_final_fields, avoid_print, use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';
import 'package:biddy/MainScreen.dart';
import 'package:biddy/components/LoginTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:biddy/components/FABcustom.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _Continue();
}

class _Continue extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String role = "";
  List<String> signInMethods = [];
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool _showFirstContainer = true;
  bool _showLogin = true;
  bool registered = false;
  void register() async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email.text.toString(),
        password: pass.text.toString(),
      );
      User? user = auth.currentUser;

      storeToken();
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .set({
          'role': pass.text.toString(),
        });
        print('Firestore data stored successfully');
      } catch (e) {
        print('Firestore error: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Your account has been created',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: Duration(seconds: 4), // SnackBar duration
      ));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {}
      }
    }
  }

  void storeToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          storeToken();
          print('Signed in with Google: ${user.displayName}');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          print('User is null after successful sign-in');
        }
      } else {
        print('Google Sign-In account is null');
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }

  void login() async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email.text.toString(), password: pass.text.toString());
      final User? user = userCredential.user;
      print('$user');
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          role = data['role'] as String;
          print('Role: $role');
          email.clear();
          pass.clear();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  Future<bool> isEmailRegistered(
      BuildContext context, TextEditingController mail) async {
    bool registered = false;
    try {
      String email = mail.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Email is empty',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          duration: Duration(seconds: 2),
        ));
        return false; // Email is empty, so registration check is not applicable
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: "placeholderPassword", // Use a non-sensitive placeholder
      );

      await FirebaseAuth.instance.currentUser!.delete();

      print("NOT registered"); // Email does not exist
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("registered");
        registered = true; // Email already exists
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Email is invalid',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          duration: Duration(seconds: 2),
        ));
      }
    }

    return registered;
  }

  void _checkEmailRegistration(BuildContext context) async {
    bool isRegistered = await isEmailRegistered(context, email);

    setState(() {
      _showLogin = isRegistered;
    });

    if (isRegistered) {
      print("User is already registered");
    } else {
      print("User is not registered");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
              Color.fromARGB(255, 241, 223, 223),
              Color.fromARGB(255, 255, 149, 163)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 230,
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            left: _showFirstContainer
                                ? 2
                                : -MediaQuery.of(context).size.width,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.28,
                              height: 180,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(12),
                                color: Color.fromARGB(255, 255, 218, 223),
                              ),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    "Welcome to Biddy", //FIRST CONTAINER
                                    style: TextStyle(
                                      fontSize: 29,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  LoginTextField(
                                    textEditingController: email,
                                    hintText: 'Email',
                                    obscureText: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            right: _showFirstContainer
                                ? -MediaQuery.of(context).size.width
                                : 7,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.29,
                              height: 180,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(12),
                                color: Color.fromARGB(255, 255, 218, 223),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    //SECOND CONTAINER
                                    padding: const EdgeInsets.only(right: 40.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showFirstContainer =
                                                  !_showFirstContainer;
                                            });
                                          },
                                          icon: Icon(Icons.arrow_back),
                                          color: Colors.black,
                                        ),
                                        Text(
                                          _showLogin ? "Login" : "Signup",
                                          style: TextStyle(
                                            fontSize: 29,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(), // For space between dont remove
                                      ],
                                    ),
                                  ),
                                  LoginTextField(
                                    textEditingController: pass,
                                    hintText: "Password",
                                    obscureText: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FABcustom(
                        onTap: () {
                          if (_showLogin) {
                            print(_showLogin);
                            login();
                            pass.clear();
                          }
                          if (_showFirstContainer) {
                            _checkEmailRegistration(context);
                          }
                          print(_showLogin);
                          if (_showLogin == false &&
                              _showFirstContainer == false) {
                            print("register triggered");
                            register();
                          }
                          _showFirstContainer = !_showFirstContainer;
                        },
                        text: _showLogin ? "Continue" : "Sign Up"),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pink, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 30, top: 18, bottom: 18),
                        child: Text('Continue without account',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0)),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Divider(
                      thickness: 2, // Adjust thickness as needed
                      color: Colors.white, // Set color according to your design
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        signInWithGoogle(context);
                      },
                      icon: Image.asset(
                        'lib/images/google.png', // Replace this with the path to your Google logo asset
                        height: 24.0,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.only(
                            left: 50.0, right: 60, top: 18, bottom: 18),
                        child: Text('Sign in with Google'),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2.0,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
