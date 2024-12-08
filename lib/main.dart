import 'package:flutter/material.dart';
import 'package:krishimitra/screens/home.dart';
import 'package:krishimitra/screens/signin.dart';
import 'package:krishimitra/screens/first.dart';
import 'package:krishimitra/screens/signup.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrishiMitra',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FirstScreen(),
      routes: {
        '/home': (context) => HomePage(),
        '/signup': (context) => Signup(),
        '/signin': (context) => const LoginScreen(),
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}
