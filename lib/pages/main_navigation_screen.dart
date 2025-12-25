import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'healthy_living_screen.dart';
import 'settings_screen.dart';
import '../services/background_permission_service.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

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

  List<String> _getLabels(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      localizations!.medicines,
      localizations!.history,
      localizations!.healthyLiving,
      localizations!.settings,
    ];
  }

  final List<IconData> _icons = [
    Icons.alarm,
    Icons.history,
    Icons.favorite,
    Icons.settings,
  ];

  @override
  void initState() {
    super.initState();
    // Uygulama açıldığında izinleri kontrol et ve pending alarm'ları kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        BackgroundPermissionService.instance.checkAndRequestPermissions(context);
        // Pending alarm varsa alarm ekranını aç
        await NotificationService.instance.checkAndOpenPendingAlarms();
      }
    });
  }

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
          final labels = _getLabels(context);
          return BottomNavigationBarItem(
            icon: Icon(icon),
            label: labels[index],
          );
        }).toList(),
      ),
    );
  }
}
