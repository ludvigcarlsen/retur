import 'package:flutter/material.dart';
import 'package:retur/screens/trip.dart';

import 'home.dart';

class NavigateScreens extends StatefulWidget {
  const NavigateScreens({super.key});

  @override
  State<StatefulWidget> createState() => _NavigateScreens();
}

class _NavigateScreens extends State<NavigateScreens> {
  int _selectedTab = 0;

  final List _pages = [
    const Center(
      child: Home(),
    ),
    const Center(
      child: Trip(),
    ),
  ];

  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pizza),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tram_sharp),
            label: 'Trip',
          ),
        ],
        currentIndex: _selectedTab,
        selectedItemColor: Colors.blue[800],
        onTap: (index) => _changeTab(index),
      ),
    ));
  }
}
