import 'package:biddy/ContinueAdBetter.dart';
import 'package:biddy/Easypaisa.dart';
import 'package:biddy/ContinueAccount.dart';
import 'package:biddy/Jazzcash.dart';
import 'package:biddy/Payment.dart';
import 'package:biddy/card.dart';
import 'package:biddy/chatPage.dart';
import 'package:biddy/Signing.dart';
//import 'package:biddy/ContinueAd.dart';
import 'package:biddy/PickImagesForAd.dart';
import 'package:biddy/MainScreen.dart';
import 'package:biddy/AdOpened.dart';
import 'package:biddy/circleavatar.dart';
import 'package:biddy/test.dart';
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
        '/Test': (context) => const Test(),
        '/LoginPage': (context) => const LoginPage(),
        '/ContinueAd': (context) => ContinueAdBetter(
            uploadImagesFuture:
                Future.value(AdData(titleURL: '', pictureUrls: []))),
        '/itemScreen': (context) => const ItemsScreen(),
        '/chatPage': (context) => ChatPage(),
        '/payment': (context) => Payment(),
        '/easypaisa': (context) => Easypaisa(),
        '/jazzcash': (context) => Jazzcash(),
        '/circleavatar': (context) => CircleAvatarFromGallery(),
        '/creditcard': (context) => CreditCardForm(),
        '/finalizeaccount': (context) => Continueaccount()
      },
      home: MainPage(),
    );
  }
}
