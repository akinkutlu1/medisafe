import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/hesabim.dart';
import 'pages/alamlar.dart';
import 'pages/gecmis.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.pink,
      ),
      debugShowCheckedModeBanner: false,
      home: const BottomNavigationExample(),
    );
  }
}

class BottomNavigationExample extends StatefulWidget {
  const BottomNavigationExample({super.key});

  @override
  State<BottomNavigationExample> createState() =>
      _BottomNavigationExampleState();
}

class _BottomNavigationExampleState extends State<BottomNavigationExample> {
  int _selectedIndex = 0;

  // Sayfa listemiz:
  final List<Widget> _pages = const [
    HomePage(),
    HesabimPage(),
    AlamlarPage(),
    GecmisPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Seçilen sayfa burada değişiyor
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          children: [
            buildNavButton(0, Icons.home, 'Home'),
            buildNavButton(1, Icons.history, 'Geçmiş'),
            buildNavButton(2, Icons.alarm, 'Alamlar'),
            buildNavButton(3, Icons.person, 'Hesabım'),
          ],
        ),
      ),
    );
  }

  Widget buildNavButton(int index, IconData icon, String label) {
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _selectedIndex == index
              ? Colors.black
              : Colors.grey, // seçili olan siyah
        ),
        onPressed: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            Text(label),
          ],
        ),
      ),
    );
  }
}
