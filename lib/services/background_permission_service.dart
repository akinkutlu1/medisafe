import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class BackgroundPermissionService {
  BackgroundPermissionService._();
  static final BackgroundPermissionService instance = BackgroundPermissionService._();
  bool _isChecking = false;

  /// Uygulama açıldığında tüm gerekli izinleri sıralı olarak kontrol et ve iste
  Future<void> checkAndRequestPermissions(BuildContext? context) async {
    if (_isChecking || context == null) return;
    _isChecking = true;

    try {
      // 1. ÖNCE: Bildirim izni (Android 13+)
      final notificationStatus = await Permission.notification.status;
      if (notificationStatus.isDenied && context.mounted) {
        final status = await Permission.notification.request();
        if (status.isDenied) {
          final shouldContinue = await _showPermissionDialog(
            context,
            'Bildirim İzni',
            'Alarmların çalışması için bildirim izni gereklidir. Lütfen ayarlardan bildirim iznini açın.',
            () => AppSettings.openAppSettings(),
          );
          // Kullanıcı "Daha Sonra" dediyse devam et, "Ayarlara Git" dediyse bekle
          if (!shouldContinue) return;
        }
      }

      // 2. İKİNCİ: Tam zamanlı alarm izni (Android 12+)
      if (await Permission.scheduleExactAlarm.isDenied && context.mounted) {
        final status = await Permission.scheduleExactAlarm.request();
        if (status.isDenied) {
          final shouldContinue = await _showPermissionDialog(
            context,
            'Tam Zamanlı Alarm İzni',
            'Alarmların tam zamanında çalışması için tam zamanlı alarm izni gereklidir. Lütfen ayarlardan bu izni açın.',
            () => AppSettings.openAppSettings(),
          );
          // Kullanıcı "Daha Sonra" dediyse devam et, "Ayarlara Git" dediyse bekle
          if (!shouldContinue) return;
        }
      }

      // 3. SON: Pil optimizasyonu kontrolü
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      if (batteryStatus.isDenied && context.mounted) {
        final shouldContinue = await _showPermissionDialog(
          context,
          'Pil Optimizasyonu',
          'Alarmların arka planda çalışması için pil optimizasyonundan muaf tutulması gereklidir. Lütfen ayarlardan pil optimizasyonunu kapatın.',
          () async {
            await Permission.ignoreBatteryOptimizations.request();
            await AppSettings.openAppSettings();
          },
        );
        // Son izin olduğu için shouldContinue'u kullanmıyoruz
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Battery optimization iznini kontrol et
  Future<bool> isBatteryOptimizationIgnored() async {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  /// Battery optimization ayarlarına yönlendir
  Future<void> openBatteryOptimizationSettings() async {
    await Permission.ignoreBatteryOptimizations.request();
    await AppSettings.openAppSettings();
  }

  /// Bildirim ayarlarına yönlendir
  Future<void> openNotificationSettings() async {
    // app_settings paketinde openNotificationSettings yok, genel ayarlara yönlendir
    await AppSettings.openAppSettings();
  }

  /// Tüm ayarları aç
  Future<void> openAllSettings() async {
    await AppSettings.openAppSettings();
  }

  /// İzin diyaloğunu gösterir
  /// Returns: true = kullanıcı "Daha Sonra" dedi (devam et), false = "Ayarlara Git" dedi (bekle)
  Future<bool> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) async {
    if (!context.mounted) return true; // Context yoksa devam et
    
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // "Daha Sonra" = true (devam et)
            child: const Text('Daha Sonra'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false); // "Ayarlara Git" = false (bekle)
              onConfirm();
            },
            child: const Text('Ayarlara Git'),
          ),
        ],
      ),
    );
    
    return result ?? true; // Null ise devam et
  }
}

