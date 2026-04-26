import 'package:flutter/material.dart';

import 'home_page.dart';
import 'task_page.dart';
import 'counter_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final pages = const [
    HomePage(),
    TaskFeedPage(),
    CounterPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0A0A),

        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,

        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        type: BottomNavigationBarType.fixed,

        currentIndex: index,
        onTap: (i) => setState(() => index = i),

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.countertops), label: "Counter"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}