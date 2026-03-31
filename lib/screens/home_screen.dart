import 'package:flutter/material.dart';
import 'package:sefyra/screens/send_screen.dart';
import 'package:sefyra/screens/recieve_screen.dart';
import 'package:sefyra/screens/settings_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  var _selectedIndex = 0;
  final List<Widget> _pages = [
    SendScreen(),
    RecieveScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.menu,
          size: 32,
        ),
        title: Text(
          "Sefyra",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.send_outlined,
            ),
            label: "Send",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.download_outlined,
            ),
            label: "Recieve",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
            ),
            label: "Settings",
          ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}
