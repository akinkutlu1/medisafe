import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/hesabim.dart';
import 'pages/alamlar.dart';
import 'pages/gecmis.dart';
import 'pages/login.dart'; // login.dart da import edildi

void main() {
  runApp(const MyApp());
}

// Kullanıcının giriş yapıp yapmadığı burada tutuluyor
bool isLoggedIn = false;

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

// Bu class eksikti, tamamlandı
class BottomNavigationExample extends StatefulWidget {
  const BottomNavigationExample({Key? key}) : super(key: key);

  @override
  _BottomNavigationExampleState createState() =>
      _BottomNavigationExampleState();
}

class _BottomNavigationExampleState extends State<BottomNavigationExample> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AlamlarPage(),
    GecmisPage(),
    HesabimPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      // Hesabım tıklandıysa
      if (isLoggedIn) {
        setState(() {
          _selectedIndex = index;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        ).then((value) {
          if (isLoggedIn) {
            setState(() {
              _selectedIndex = 3;
            });
          }
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          children: [
            buildNavButton(0, Icons.home, 'Ana Sayfa'),
            buildNavButton(1, Icons.alarm, 'Alamlar'),
            buildNavButton(2, Icons.history, 'Geçmiş'),
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
          foregroundColor: _selectedIndex == index ? Colors.black : Colors.grey,
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
