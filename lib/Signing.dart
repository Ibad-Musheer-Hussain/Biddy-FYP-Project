// ignore_for_file: file_names, prefer_final_fields, avoid_print, use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';
import 'package:biddy/ForgotPasswordDialog.dart';
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
          'balance': 0,
          'name': "change in signing.dart",
          'history': [],
          'favourites': [],
          'Userads': [],
          'chats': []
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

      Navigator.pushNamed(context, '/finalizeaccount');
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

    if (email.text.isNotEmpty) {
      setState(() {
        _showLogin = isRegistered;
      });
    }

    if (isRegistered) {
      print("User is already registered");
    } else {
      print("User is not registered");
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ForgotPasswordDialog();
      },
    );
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
                    Center(
                      child: Container(
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
                                height: 217.5,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color.fromARGB(255, 255, 218, 223),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "   Login or Signup",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "    Get Started for free",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black38,
                                      ),
                                    ),
                                    LoginTextField(
                                      textEditingController: email,
                                      hintText: 'Email',
                                      obscureText: false,
                                    ),
                                    Transform.translate(
                                      offset: Offset(0, 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 70.0),
                                            child: TextButton(
                                                onPressed: () {
                                                  _showForgotPasswordDialog(
                                                      context);
                                                },
                                                child: Text(
                                                  "Forgot Password",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color: Colors.black38,
                                                  ),
                                                )),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MainPage()),
                                                );
                                              },
                                              child: Text(
                                                "Guest Login",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors.black38,
                                                ),
                                              ))
                                        ],
                                      ),
                                    )
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
                                height: 217.5,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color.fromARGB(255, 255, 218, 223),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _showLogin ? "  Login" : "  Signup",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showFirstContainer =
                                                  !_showFirstContainer;
                                            });
                                          },
                                          icon: Icon(Icons.close),
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Transform.translate(
                                      offset: Offset(0, -12),
                                      child: Text(
                                        "   Get Started for free",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: Offset(0, -4),
                                      child: LoginTextField(
                                        textEditingController: pass,
                                        hintText: "Password",
                                        obscureText: true,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 70.0),
                                          child: TextButton(
                                              onPressed: () {},
                                              child: Text(
                                                "Forgot Password",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors.black38,
                                                ),
                                              )),
                                        ),
                                        TextButton(
                                            onPressed: () {},
                                            child: Text(
                                              "Guest Login",
                                              style: TextStyle(
                                                fontSize: 13,
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Colors.black38,
                                              ),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        text: _showLogin ? "Continue with email" : "Sign Up"),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "or",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        signInWithGoogle(context);
                      },
                      icon: Image.asset(
                        'lib/images/google.png',
                        height: 24.0,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.only(
                            left: 45.0, right: 50, top: 18, bottom: 18),
                        child: Text(
                          'Continue with Google              ',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
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
