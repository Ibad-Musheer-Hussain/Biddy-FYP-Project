//import 'package:biddy/SearchPage.dart';
// ignore_for_file: prefer_const_constructors
import 'package:biddy/Signing.dart';
import 'package:biddy/ContinueAd.dart';
import 'package:biddy/PickImagesForAd.dart';
import 'package:biddy/MainScreen.dart';
import 'package:biddy/AdOpened.dart';
// ignore: unused_import
import 'package:biddy/test.dart';
//import 'package:biddy/ml.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/MainPage': (context) => const MainPage(),
        '/CreateAd': (context) => const CreateAd(),
        '/LoginPage': (context) => const LoginPage(),
        '/ContinueAd': (context) => ContinueAd(
            uploadImagesFuture:
                Future.value(AdData(titleURL: '', pictureUrls: []))),
        '/itemScreen': (context) => const ItemsScreen()
      },

      home: MainPage(),
      //home: FavPage(),
    );
  }
}
