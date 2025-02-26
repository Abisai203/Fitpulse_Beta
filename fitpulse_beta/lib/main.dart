// main.dart
import 'package:fitpulse_beta/screens/animation.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Fitpulse_beta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/Splash',
      routes: {
        '/Splash': (context) => SplashScreen(),
      },
    );
  }
}
