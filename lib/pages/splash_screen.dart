import 'package:flutter/material.dart';
import 'auth_wrapper.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String _welcomeMessage;

  @override
  void initState() {
    super.initState();
    _navigateToAuthWrapper();
  }

  List<String> _getLocalizedMessages(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.splashMessage1,
      localizations.splashMessage2,
      localizations.splashMessage3,
      localizations.splashMessage4,
      localizations.splashMessage5,
    ];
  }

  _navigateToAuthWrapper() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    if (mounted) {
      // Uygulama kapalıyken açıldıysa payload'ı flush et
      NotificationService.instance.flushPendingPayload();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _getLocalizedMessages(context);
    _welcomeMessage = messages[DateTime.now().millisecondsSinceEpoch % messages.length];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Image.asset(
              'assets/images/reminder.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            Text(
              _welcomeMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
