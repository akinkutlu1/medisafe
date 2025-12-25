import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  NotificationService.instance._handlePayload(notificationResponse.payload);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? navigatorKey;
  String? _pendingPayload;
  String? _lastProcessedPayload;
  DateTime? _lastProcessedTime;
  bool _isOpeningAlarm = false; // Alarm ekranı açılıyor mu kontrolü
  // Kullanıcı alarm ekranına girmediyse tekrar planlama için
  final Map<String, DateTime> _pendingAlarms = {}; // docPath -> alarm zamanı

  static const String _channelId = 'medisafe_channel';
  static const String _channelName = 'MediSafe';

  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    if (navigatorKey != null) {
      this.navigatorKey = navigatorKey;
    }
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {
        debugPrint('📱 Bildirim yanıtı alındı: ${resp.payload}');
        _handlePayload(resp.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Android bildirim kanalını oluştur
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.max,
          description: 'İlaç hatırlatma bildirimleri',
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('digital_alarm_02_151919'),
        ),
      );
      debugPrint('✅ Bildirim kanalı oluşturuldu: $_channelName');
    }

    final details = await _plugin.getNotificationAppLaunchDetails();
    final launchedFromNotification = details?.didNotificationLaunchApp ?? false;
    if (launchedFromNotification) {
      final payload = details?.notificationResponse?.payload;
      debugPrint('📱 Uygulama bildirimden açıldı, payload: $payload');
      if (payload != null && payload.isNotEmpty) {
        _pendingPayload = payload; // Navigator hazır olana kadar beklet
      }
    }
  }

  Future<void> requestPermissions() async {
    // Android notifications work by default, no permission request needed
    // For Android 13+, users can grant notification permission in system settings
    // Full screen intent izni AndroidManifest.xml'de tanımlı
    
    // iOS için bildirim izinleri
    final iosImplementation = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Debug amaçlı: uygulama çalışırken anlık test bildirimi göster
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Test bildirimi',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      9999,
      'Test alarm',
      'Bu bir test bildirimidir',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'TEST|debug',
    );
    debugPrint('🔔 Test bildirimi gösterildi (showTestNotification)');
  }

  Future<void> scheduleMedicineReminder({
    required String docPath,
    required String medicineName,
    required DateTime at,
    String? body,
    String? imageFileName,
  }) async {
    // Exact alarm izni bazı cihazlarda/emülatörlerde sorun çıkardığı için
    // artık zorunlu tutmuyoruz. Android, inexactAllowWhileIdle modunda
    // bu izne gerek duymadan bildirimleri tetikleyebiliyor.

    // Kullanıcının seçtiği alarm sesini al
    String? soundAsset;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        soundAsset = userDoc.data()?['alarmSound'] as String?;
      }
    } catch (e) {
      debugPrint('⚠️ Alarm sesi alınamadı: $e');
    }

    AndroidBitmap<Object>? largeIconBitmap;
    if (imageFileName != null && imageFileName.isNotEmpty) {
      try {
        final bytes = await rootBundle
            .load('assets/medimages/$imageFileName'); // Excel'deki isim
        final dir = await getTemporaryDirectory();
        final file = File(
            '${dir.path}/notif_${imageFileName.hashCode}_${docPath.hashCode}.jpg');
        await file.writeAsBytes(
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        largeIconBitmap = FilePathAndroidBitmap(file.path);
      } catch (e) {
        debugPrint('⚠️ Bildirim resmi yüklenemedi: $e');
      }
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'İlaç hatırlatma bildirimleri',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true, // Full-screen intent için gerekli
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
      largeIcon:
          largeIconBitmap ?? const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ongoing: false,
      autoCancel: false,
      showWhen: true,
      when: at.millisecondsSinceEpoch,
      ticker: 'İlacınızı almayı unutmayın',
      styleInformation: const BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[],
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Exact alarm iznini kontrol et (Android 12+)
    try {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (exactAlarmStatus.isDenied) {
        debugPrint('⚠️ Exact alarm izni yok! Bildirim tam zamanında çalışmayabilir.');
        // İzni iste
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      debugPrint('⚠️ Exact alarm izni kontrol edilemedi: $e');
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(at, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    final diff = scheduledDate.difference(now).inSeconds;

    debugPrint(
        '📆 Bildirim zamanlama isteği: $medicineName - hedef: $scheduledDate (şimdi: $now, fark: ${diff}s)');

    try {
      await _plugin.zonedSchedule(
        _notificationId(docPath),
        medicineName,
        body ?? 'İlacınızı almayı unutmayın',
        scheduledDate,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        // Exact alarm - mümkün olduğunca zamanında çalsın
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        payload: '$medicineName|$docPath',
        // Tek seferlik kesin alarm; matchDateTimeComponents kullanmıyoruz
      );
      
      debugPrint('📢 Bildirim planlandı: $medicineName - $scheduledDate');
    } catch (e) {
      debugPrint('❌ Bildirim planlama hatası: $e');
      // Hata durumunda tekrar dene (inexact mod ile)
      try {
        await _plugin.zonedSchedule(
          _notificationId(docPath),
          medicineName,
          body ?? 'İlacınızı almayı unutmayın',
          scheduledDate,
          NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          payload: '$medicineName|$docPath',
        );
        debugPrint('📢 Bildirim planlandı (inexact mod): $medicineName - $scheduledDate');
      } catch (e2) {
        debugPrint('❌ Bildirim planlama hatası (inexact mod): $e2');
        rethrow;
      }
    }
  }

  Future<void> cancelMedicineReminder(String docPath) async {
    await _plugin.cancel(_notificationId(docPath));
  }

  int _notificationId(String docPath) => docPath.hashCode;

  String reminderBody(Map<String, dynamic> medicineData) {
    final String regimen = medicineData['regimen'] as String? ?? '';
    if (regimen == 'Saatlik') {
      final dynamic raw = medicineData['intervalHours'];
      final int interval = raw is int ? raw : int.tryParse('$raw') ?? 0;
      // Kullanıcıya gösterilecek metni sabit tutuyoruz
      // (kaç saatte bir olduğuna bakmadan)
      if (interval > 0) {
        return 'İlacınızı alınız';
      }
      return 'İlacınızı alınız';
    }
    return 'Öğünden sonra alın';
  }

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      debugPrint('⚠️ Bildirim payload boş');
      return;
    }
    
    // Eğer zaten bir alarm ekranı açılıyorsa, yeni bir tane açma
    if (_isOpeningAlarm) {
      debugPrint('⚠️ Alarm ekranı zaten açılıyor, payload işlenmiyor: $payload');
      return;
    }
    
    // Aynı payload'un kısa süre içinde tekrar işlenmesini engelle
    final now = DateTime.now();
    if (_lastProcessedPayload == payload && 
        _lastProcessedTime != null && 
        now.difference(_lastProcessedTime!).inSeconds < 3) {
      debugPrint('⚠️ Aynı payload zaten işlendi, tekrar işlenmiyor: $payload');
      return;
    }
    
    _lastProcessedPayload = payload;
    _lastProcessedTime = now;
    
    final parts = payload.split('|');
    if (parts.length < 2) {
      debugPrint('⚠️ Bildirim payload formatı hatalı: $payload');
      return;
    }
    final String name = parts[0];
    final String path = parts[1];

    debugPrint('📱 Bildirim payload işleniyor: $name - $path');

    // Alarm zamanını kaydet (kullanıcı alarm ekranına girmezse tekrar planlamak için)
    _pendingAlarms[path] = now;

    // Navigator hazır olana kadar bekle
    _waitForNavigatorAndOpen(payload, name, path);
    
    // Eğer kullanıcı 2 dakika içinde alarm ekranına girmezse, alarmı tekrar planla
    Future.delayed(const Duration(minutes: 2), () {
      // Eğer hala pending alarms listesindeyse, kullanıcı alarm ekranına girmemiş demektir
      if (_pendingAlarms.containsKey(path)) {
        debugPrint('⏰ Kullanıcı alarm ekranına girmedi, alarm tekrar planlanıyor: $name');
        _reschedulePendingAlarm(path, name);
      }
    });
  }
  
  Future<void> _reschedulePendingAlarm(String docPath, String medicineName) async {
    try {
      // Firestore'dan ilaç bilgilerini al
      final docRef = FirebaseFirestore.instance.doc(docPath);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        _pendingAlarms.remove(docPath);
        return;
      }
      
      final data = snapshot.data() ?? {};
      final DateTime? firstReminder = _parseTimestamp(data['firstReminder']);
      final DateTime now = DateTime.now();
      
      // Bir sonraki alarm zamanını hesapla
      DateTime? nextAlarm;
      if (firstReminder != null && firstReminder.isAfter(now)) {
        nextAlarm = firstReminder;
      } else {
        // Bir sonraki alarm zamanını hesapla
        final String regimen = data['regimen'] ?? '';
        if (regimen == 'Saatlik') {
          final dynamic intervalRaw = data['intervalHours'];
          if (intervalRaw == null) {
            // Test modu - 1 dakika sonra
            nextAlarm = now.add(const Duration(minutes: 1));
          } else {
            final int interval = intervalRaw is int ? intervalRaw : int.tryParse('$intervalRaw') ?? 0;
            if (interval > 0) {
              nextAlarm = now.add(Duration(hours: interval));
            }
          }
        } else {
          // Öğünlere göre - şimdilik mevcut firstReminder'ı kullan
          nextAlarm = firstReminder;
        }
      }
      
      // Eğer nextAlarm bir sonraki alarm zamanından önceyse, tekrar planla
      if (nextAlarm != null && nextAlarm.isAfter(now)) {
        // 2 dakika sonra tekrar alarm çal
        final retryTime = now.add(const Duration(minutes: 2));
        if (retryTime.isBefore(nextAlarm)) {
          await scheduleMedicineReminder(
            docPath: docPath,
            medicineName: medicineName,
            at: retryTime,
            body: reminderBody(data),
            imageFileName: data['imageFileName'] as String?,
          );
          debugPrint('✅ Alarm tekrar planlandı: $medicineName - $retryTime (bir sonraki alarm: $nextAlarm)');
          // Pending alarms listesinde tut (bir sonraki alarm zamanına kadar)
          _pendingAlarms[docPath] = retryTime;
          
          // Eğer hala bir sonraki alarm zamanından önceyse, tekrar planla
          Future.delayed(const Duration(minutes: 2), () {
            if (_pendingAlarms.containsKey(docPath)) {
              _reschedulePendingAlarm(docPath, medicineName);
            }
          });
        } else {
          // Bir sonraki alarm zamanı geldi, pending'den kaldır
          _pendingAlarms.remove(docPath);
          debugPrint('✅ Bir sonraki alarm zamanı geldi, pending alarm kaldırıldı: $medicineName');
        }
      } else {
        // Bir sonraki alarm zamanı geçmiş, pending'den kaldır
        _pendingAlarms.remove(docPath);
        debugPrint('✅ Bir sonraki alarm zamanı geçmiş, pending alarm kaldırıldı: $medicineName');
      }
    } catch (e) {
      debugPrint('❌ Alarm tekrar planlama hatası: $e');
      _pendingAlarms.remove(docPath);
    }
  }
  
  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
  
  void clearPendingAlarm(String docPath) {
    _pendingAlarms.remove(docPath);
    debugPrint('✅ Pending alarm kaldırıldı: $docPath');
  }
  
  // Uygulama açıldığında pending alarm varsa alarm ekranını aç
  Future<void> checkAndOpenPendingAlarms() async {
    if (_pendingAlarms.isEmpty) return;
    if (_isOpeningAlarm) return;
    
    final navigator = navigatorKey?.currentState;
    if (navigator == null) {
      debugPrint('⚠️ Navigator hazır değil, pending alarm kontrolü ertelendi');
      // Navigator hazır olana kadar bekle
      Future.delayed(const Duration(milliseconds: 500), () {
        checkAndOpenPendingAlarms();
      });
      return;
    }
    
    // Pending alarm'ları kontrol et
    final now = DateTime.now();
    final pendingEntries = _pendingAlarms.entries.toList();
    
    for (final entry in pendingEntries) {
      final docPath = entry.key;
      final alarmTime = entry.value;
      
      // Eğer alarm zamanı geçmişse veya çok yakınsa, alarm ekranını aç
      // 30 dakika içindeki pending alarm'ları göster
      final timeDiff = now.difference(alarmTime).inMinutes;
      if (timeDiff.abs() < 30) {
        try {
          // Firestore'dan ilaç bilgilerini al
          final docRef = FirebaseFirestore.instance.doc(docPath);
          final snapshot = await docRef.get().timeout(const Duration(seconds: 5));
          if (!snapshot.exists) {
            _pendingAlarms.remove(docPath);
            continue;
          }
          
          final data = snapshot.data() ?? {};
          final String medicineName = data['name'] ?? 'İlaç';
          
          debugPrint('📱 Pending alarm bulundu, alarm ekranı açılıyor: $medicineName (${timeDiff} dakika önce)');
          
          // Alarm ekranını aç
          _isOpeningAlarm = true;
          navigator.pushNamed(
            '/alarm',
            arguments: {
              'name': medicineName,
              'path': docPath,
            },
          ).then((_) {
            // Kullanıcı alarm ekranına girdi, pending'den kaldır
            _pendingAlarms.remove(docPath);
            _isOpeningAlarm = false;
            debugPrint('✅ Pending alarm işlendi: $medicineName');
          }).catchError((e) {
            debugPrint('❌ Pending alarm açılırken hata: $e');
            _isOpeningAlarm = false;
          });
          
          // Sadece bir alarm ekranı aç
          break;
        } catch (e) {
          debugPrint('❌ Pending alarm kontrolü hatası: $e');
          _pendingAlarms.remove(docPath);
        }
      } else if (timeDiff > 30) {
        // 30 dakikadan eski pending alarm'ları kaldır
        _pendingAlarms.remove(docPath);
        debugPrint('⚠️ Eski pending alarm kaldırıldı: $docPath (${timeDiff} dakika önce)');
      }
    }
  }

  void _waitForNavigatorAndOpen(String payload, String name, String path, {int retries = 10}) async {
    // Eğer zaten bir alarm ekranı açılıyorsa, yeni bir tane açma
    if (_isOpeningAlarm) {
      debugPrint('⚠️ Alarm ekranı zaten açılıyor, yeni ekran açılmıyor: $name');
      return;
    }

    final navigator = navigatorKey?.currentState;
    if (navigator == null) {
      if (retries > 0) {
        debugPrint('⚠️ Navigator henüz hazır değil, ${retries} deneme kaldı');
        _pendingPayload = payload;
        // 500ms sonra tekrar dene
        await Future.delayed(const Duration(milliseconds: 500));
        _waitForNavigatorAndOpen(payload, name, path, retries: retries - 1);
      } else {
        debugPrint('❌ Navigator hazır olmadı, payload bekletiliyor');
        _pendingPayload = payload;
      }
      return;
    }

    try {
      // Flag'i set et
      _isOpeningAlarm = true;
      
      // Navigator hazır, alarm ekranını aç
      // Future.microtask yerine direkt pushNamed kullan
      // Çünkü microtask bazen timing sorunlarına yol açabiliyor
      navigator?.pushNamed(
        '/alarm',
        arguments: {
          'name': name,
          'path': path,
        },
      ).then((_) {
        debugPrint('✅ Alarm ekranı açıldı ve kapatıldı: $name');
        // Kullanıcı alarm ekranına girdi, pending alarms listesinden kaldır
        _pendingAlarms.remove(path);
        // Flag'i sıfırla (alarm ekranı kapatıldıktan sonra)
        Future.delayed(const Duration(milliseconds: 500), () {
          _isOpeningAlarm = false;
        });
      }).catchError((e) {
        debugPrint('❌ Alarm ekranı açılırken hata: $e');
        _isOpeningAlarm = false;
      });
      
      debugPrint('✅ Alarm ekranı açma isteği gönderildi: $name');
    } catch (e) {
      debugPrint('❌ Alarm ekranı açılamadı: $e');
      _pendingPayload = payload;
      _isOpeningAlarm = false;
    }
  }

  void flushPendingPayload() {
    if (_pendingPayload == null) return;
    // Eğer zaten bir alarm ekranı açılıyorsa, pending payload'u işleme
    if (_isOpeningAlarm) {
      debugPrint('⚠️ Alarm ekranı açılıyor, pending payload bekletiliyor');
      return;
    }
    final payload = _pendingPayload;
    _pendingPayload = null;
    // Eğer payload zaten işlendiyse tekrar işleme
    if (_lastProcessedPayload == payload && 
        _lastProcessedTime != null && 
        DateTime.now().difference(_lastProcessedTime!).inSeconds < 3) {
      debugPrint('⚠️ Pending payload zaten işlendi, atlanıyor: $payload');
      return;
    }
    _handlePayload(payload);
  }
}




