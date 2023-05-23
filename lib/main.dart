import 'package:flutter/material.dart';
import 'package:retur/screens/trip.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Retur",
      theme: ThemeData(
          brightness: Brightness.dark,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              backgroundColor: const MaterialStatePropertyAll(
                Color.fromARGB(50, 123, 174, 245),
              ),
              foregroundColor: const MaterialStatePropertyAll(
                  Color.fromARGB(255, 81, 154, 255)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 33, 32, 37),
          sliderTheme: SliderThemeData(
              activeTrackColor: Color.fromARGB(255, 81, 154, 255)),
          cardTheme: CardTheme(
            margin: EdgeInsets.zero,
            color: const Color.fromARGB(255, 55, 55, 63),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 33, 32, 37),
          ),
          primaryColor: const Color.fromARGB(255, 33, 32, 37)),
      debugShowCheckedModeBanner: false,
      home: const Trip(),
    );
  }
}
