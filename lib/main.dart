import 'package:biddy/FinishAd.dart';
import 'package:biddy/Easypaisa.dart';
import 'package:biddy/ContinueAccount.dart';
import 'package:biddy/Jazzcash.dart';
import 'package:biddy/Payment.dart';
import 'package:biddy/Profile.dart';
import 'package:biddy/Settings.dart';
import 'package:biddy/YourAds.dart';
import 'package:biddy/creditcard.dart';
import 'package:biddy/Chat.dart';
import 'package:biddy/LoginPage.dart';
import 'package:biddy/CreateAd.dart';
import 'package:biddy/HomePage.dart';
import 'package:biddy/AdOpened.dart';
import 'package:biddy/Help.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(Duration(seconds: 3));
  await Firebase.initializeApp();
  FlutterNativeSplash.remove();
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
        '/itemScreen': (context) => const ItemsScreen(),
        '/chatPage': (context) => ChatPage(),
        '/payment': (context) => Payment(),
        '/easypaisa': (context) => Easypaisa(),
        '/jazzcash': (context) => Jazzcash(),
        '/creditcard': (context) => CreditCardForm(),
        '/finalizeaccount': (context) => Continueaccount(),
        '/profile': (context) => Profile(),
        '/YourAds': (context) => Yourads(),
        '/help': (context) => Help(),
        '/settings': (context) => Setting(),
        '/CombineAd': (context) => Continueadcombine(
            uploadImagesFuture:
                Future.value(AdData(titleURL: '', pictureUrls: []))),
      },
      home: MainPage(),
    );
  }
}
