import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'URM_Project',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SignInScreen(),
        routes: {
          '/homie': (context) =>
              Homie(), 
          '/home': (context) =>
              const Home(), 
          '/signin': (context) =>
              const SignInScreen(), 
          '/manual': (context) =>
              Manual(), 
        });
  }
}

void main() {
  runApp(const MyApp());
}
