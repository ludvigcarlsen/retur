import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:retur/screens/main_navigation.dart';
import 'package:retur/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.setAppGroupId('group.returwidget');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Retur",
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}
