import 'package:flutter/material.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String _welcomeMessage;

  final List<String> _messages = [
    "İlaçlarını zamanında al, sağlığını koru.",
    "Sağlığın için buradayız.",
    "İlacını unutma, hayatını kolaylaştır.",
    "Sağlıklı bir yaşam,\n zamanında alınan ilaçla başlar.",
    "Her dozda sağlık, her bildirimde huzur."
  ];

  @override
  void initState() {
    super.initState();
    _welcomeMessage = _messages[DateTime.now().millisecondsSinceEpoch % _messages.length];
    _navigateToAuthWrapper();
  }

  _navigateToAuthWrapper() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
