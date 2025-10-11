import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'healthy_living_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const HealthyLivingScreen(),
    const SettingsScreen(),
  ];

  final List<String> _labels = [
    'Alarmlar',
    'Geçmiş',
    'Sağlıklı Yaşam',
    'Ayarlar',
  ];

  final List<IconData> _icons = [
    Icons.alarm,
    Icons.history,
    Icons.favorite,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1E66A6),
        unselectedItemColor: Colors.grey,
        items: _icons.asMap().entries.map((entry) {
          final index = entry.key;
          final icon = entry.value;
          return BottomNavigationBarItem(
            icon: Icon(icon),
            label: _labels[index],
          );
        }).toList(),
      ),
    );
  }
}
