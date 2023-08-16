import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:ocrcustomer/pages/faq_page.dart';
import 'package:ocrcustomer/pages/home_page.dart';
import 'package:ocrcustomer/pages/loading_page.dart';
import 'package:ocrcustomer/pages/login_screen.dart';
import 'package:ocrcustomer/pages/scanfile.dart';
import 'package:ocrcustomer/pages/signup_page.dart';
import 'package:ocrcustomer/pages/tabbar.dart';
import 'package:ocrcustomer/pages/toxic_pages.dart';
import 'package:ocrcustomer/pages/welcomepage.dart';

import 'firebase_options.dart';

void main() async {
  //hide status bar

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: welcome(),
      routes: <String, WidgetBuilder>{
        '/faq': (BuildContext context) => FAQPage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/home': (BuildContext context) => const Tabbar(),
        '/signup': (BuildContext context) => const SignUpPage(),
        '/toxic': (BuildContext context) => const ToxicPage()
      },
    );
  }
}
