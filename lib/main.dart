import 'package:flutter/material.dart';
import 'package:retur/screens/bottomnavigationbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Retur",
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color.fromARGB(255, 33, 32, 37),
          cardColor: const Color.fromARGB(255, 55, 55, 63),
          primaryColor: const Color.fromARGB(255, 33, 32, 37)),
      debugShowCheckedModeBanner: false,
      home: const NavigateScreens(),
      
    );
  }
}
