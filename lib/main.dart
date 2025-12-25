import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'services/notification_service.dart';
import 'pages/alarm_screen.dart';

import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final navigatorKey = GlobalKey<NavigatorState>();
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);
  await NotificationService.instance.requestPermissions();

  // Initialize providers
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  await themeProvider.init();
  await localeProvider.init();

  // Background service kaldırıldı - scheduled notifications zaten arka planda çalışıyor
  // Android'in scheduled notification sistemi uygulama kapalıyken de çalışır
  // Sadece exact alarm izni ve battery optimization muafiyeti gerekiyor

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.flushPendingPayload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'MediSafe',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode == AppThemeMode.system
              ? ThemeMode.system
              : themeProvider.themeMode == AppThemeMode.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: localeProvider.supportedLocales,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: localeProvider.isRTL() ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          home: const SplashScreen(),
          navigatorKey: widget.navigatorKey,
          routes: {
        '/alarm': (context) {
          try {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final name = args?['name'] as String? ?? 'İlaç';
            final path = args?['path'] as String? ?? '';
            if (path.isEmpty) {
              // Path yoksa geri dön
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).maybePop();
              });
              return Scaffold(
                body: Center(child: Text(AppLocalizations.of(context)!.medicineNotFound)),
              );
            }
            return AlarmScreen(medicineDocPath: path, medicineName: name);
          } catch (e) {
            debugPrint('❌ Alarm ekranı açılırken hata: $e');
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.cannotOpenAlarm),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(AppLocalizations.of(context)!.goBack),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      },
        );
      },
    );
  }
}

// Notification logic moved to services/notification_service.dart
