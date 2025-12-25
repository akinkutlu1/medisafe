import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_medicine_screen.dart';
import '../services/history_service.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1E66A6);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // simple top spacing like mock
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            localizations?.manageMedicines ?? 'Manage Your Medicines',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            localizations?.manageMedicinesDescription ?? 'Add your medicines, receive timely reminders and track your health.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              localizations?.alarms ?? 'Alarms',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const _MedicineList(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddMedicineScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9B200),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localizations?.addNewMedicineButton ?? 'Add New Medicine',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _MedicineList extends StatelessWidget {
  const _MedicineList();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Text('Giriş yapmalısınız.');
    }
    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text(
            'Henüz alarm yok. Hemen bir ilaç ekleyin!',
            style: TextStyle(color: Colors.grey.shade600),
          );
        }
        return Column(
          children: docs.map((d) {
            final data = d.data();
            return Dismissible(
              key: ValueKey(d.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    final String name = data['name'] ?? '';
                    return AlertDialog(
                      title: const Text('İlaç silinsin mi?'),
                      content: Text('"$name" kaydını silmek istediğinizden emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Sil'),
                        ),
                      ],
                    );
                  },
                );
                return confirm ?? false;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                final messenger = ScaffoldMessenger.of(context);
                final String name = data['name'] ?? '';
                try {
                  // İlaç silinirken planlanmış bildirimi de iptal et
                  try {
                    await NotificationService.instance
                        .cancelMedicineReminder(d.reference.path)
                        .timeout(const Duration(seconds: 5));
                  } catch (e) {
                    debugPrint('⚠️ Bildirim iptal hatası (devam ediliyor): $e');
                  }
                  // Firestore'dan sil
                  await d.reference.delete().timeout(
                    const Duration(seconds: 10),
                    onTimeout: () {
                      throw Exception('Silme işlemi zaman aşımına uğradı');
                    },
                  );
                  if (context.mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('$name silindi')),
                    );
                  }
                } catch (e) {
                  debugPrint('❌ Silme işlemi hatası: $e');
                  if (context.mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Silme işlemi başarısız: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Tamam',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                }
              },
              child: _MedicineCard(doc: d),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MedicineCard extends StatefulWidget {
  const _MedicineCard({required this.doc});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  State<_MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<_MedicineCard> {
  Timer? _timer;
  Duration? _remaining;
  bool _autoDeleted = false;
  Map<String, dynamic>? _localDataOverride;
  bool _updatingFirstReminder = false; // firstReminder güncelleniyor mu kontrolü

  @override
  void initState() {
    super.initState();
    // İlk güncellemeyi hemen yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateRemaining();
        _ensureNotificationScheduled();
      }
    });
    // Her saniye geri sayımı güncelle
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateRemaining();
      }
    });
  }

  Future<void> _ensureNotificationScheduled() async {
    final data = _currentData();
    if (data['alarmOn'] != true) return;

    // firstReminder'ı direkt Firestore'dan oku
    final firstReminderTs = data['firstReminder'];
      if (firstReminderTs == null) {
      // firstReminder yoksa hesapla
      final nextReminder = _computeNextReminder(data);
      if (nextReminder == null) return;

      final now = DateTime.now();
      if (nextReminder.isAfter(now)) {
        try {
          await NotificationService.instance.scheduleMedicineReminder(
            docPath: widget.doc.reference.path,
            medicineName: data['name'] ?? 'İlaç',
            at: nextReminder,
            body: NotificationService.instance.reminderBody(data),
            imageFileName: data['imageFileName'] as String?,
          );
          final localTime = nextReminder.toLocal();
          debugPrint('✅ Bildirim planlandı: ${data['name']} - Yerel: ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}');
        } catch (e) {
          debugPrint('❌ Bildirim planlama hatası: $e');
        }
      }
    } else {
      // firstReminder varsa onu kullan
      final firstReminder = _parseTimestamp(firstReminderTs);
      if (firstReminder == null) return;

      final now = DateTime.now();
      if (firstReminder.isAfter(now)) {
        try {
          await NotificationService.instance.scheduleMedicineReminder(
            docPath: widget.doc.reference.path,
            medicineName: data['name'] ?? 'İlaç',
            at: firstReminder,
            body: NotificationService.instance.reminderBody(data),
            imageFileName: data['imageFileName'] as String?,
          );
          final localTime = firstReminder.toLocal();
          debugPrint('✅ Bildirim planlandı (firstReminder): ${data['name']} - Yerel: ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}');
        } catch (e) {
          debugPrint('❌ Bildirim planlama hatası: $e');
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant _MedicineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Streamden yeni veri geldiğinde lokal override'ı sıfırla
    _localDataOverride = null;
    if (!mapEquals(oldWidget.doc.data(), widget.doc.data())) {
      _updateRemaining();
      // Veri değiştiğinde bildirimi yeniden planla
      _ensureNotificationScheduled();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    if (_autoDeleted || !mounted) return;
    try {
      final data = _currentData();
      if (_isExpired(data)) {
        _autoDeleted = true;
        _timer?.cancel();
        widget.doc.reference.delete().catchError((e) {
          debugPrint('❌ Otomatik silme hatası: $e');
        });
        return;
      }
      final next = _computeNextReminder(data);
      final now = DateTime.now();
      Duration? value;

      if (next != null) {
        value = next.difference(now);
        if (value.isNegative) {
          // Eğer alarm zamanı geçmişse, bir sonraki alarm zamanını hesapla
          // Bu durumda bildirim zaten çalmış olmalı, ama geri sayımı güncelle
          value = Duration.zero;
          // Bir sonraki alarm zamanını yeniden hesapla
          _ensureNotificationScheduled();
        }
      } else {
        value = null;
        // next null ise, bildirimi yeniden planlamayı dene
        if (data['alarmOn'] == true) {
          debugPrint('⚠️ Sonraki hatırlatma hesaplanamadı, yeniden planlanıyor: ${data['name']}');
          _ensureNotificationScheduled();
        }
      }

      // Alarm zamanı geldiğinde bildirim zaten alarm sayfasını açacak,
      // bu yüzden HomeScreen'deki timer sadece geri sayımı gösterir,
      // alarm sayfasını açmaz.

      if (mounted) {
        setState(() {
          _remaining = value;
        });
      }
    } catch (e) {
      debugPrint('❌ Geri sayım güncelleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData();
    final String name = data['name'] ?? '';
    final String type = data['type'] ?? '';
    final String regimen = data['regimen'] ?? '';
    final int? interval = data['intervalHours'];
    final String intervalText = regimen == 'Saatlik'
        ? (interval != null ? AppLocalizations.of(context)!.everyXHours(interval) : AppLocalizations.of(context)!.hourly)
        : AppLocalizations.of(context)!.mealBased;
    final List<String> subtitleParts = [
      if (type.isNotEmpty) type,
      intervalText,
    ];
    final String subtitle = subtitleParts.join(' • ');
    final String countdownLabel = _remaining == null
        ? AppLocalizations.of(context)!.notScheduled
        : _remaining == Duration.zero
            ? AppLocalizations.of(context)!.now
            : _formatDuration(_remaining!, context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: _handleTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMedicineImage(data),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppLocalizations.of(context)!.nextAlarm,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              countdownLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineImage(Map<String, dynamic> data) {
    final String? imageFileName = data['imageFileName'] as String?;
    if (imageFileName == null || imageFileName.isEmpty) {
      return Image.asset(
        'assets/images/pill.png',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/reminder.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      'assets/medimages/$imageFileName',
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/pill.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/reminder.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
  }

  Future<void> _handleTap() async {
    if (_autoDeleted) return;
    final data = widget.doc.data();
    final String name = data['name'] ?? 'İlaç';
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('İlaç alındı mı?'),
          content: Text('"$name" ilacını aldınız mı?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _markAsTaken();
    }
  }

  Future<void> _markAsTaken() async {
    final messenger = ScaffoldMessenger.of(context);
    final data = _currentData();
    final ref = widget.doc.reference;
    final DateTime now = DateTime.now();
    final DateTime? end = _extractEndDate(data);

    DateTime? nextReminder;
    final String regimen = data['regimen'] ?? '';
    if (regimen == 'Saatlik') {
      final intervalHoursValue = data['intervalHours'];
      // Test modu kontrolü (intervalHours null ise test modu)
      if (intervalHoursValue == null) {
        // Test modu - 1 dakika sonrasına ayarla
        nextReminder = now.add(const Duration(minutes: 1));
        if (end != null && nextReminder.isAfter(end)) {
          nextReminder = null;
        }
      } else {
        final int interval = intervalHoursValue is int
            ? intervalHoursValue as int
            : int.tryParse('${intervalHoursValue}') ?? 0;
        if (interval > 0) {
          nextReminder = now.add(Duration(hours: interval));
          if (end != null && nextReminder.isAfter(end)) {
            nextReminder = null;
          }
        }
      }
    } else {
      final rawTimes = data['mealTimes'];
      if (rawTimes is List) {
        final times = rawTimes.map((e) => e.toString()).toList();
        final DateTime start = _parseTimestamp(data['startDate']) ?? now;
        nextReminder = _findNextMealReminder(times, start, now, end);
      }
    }

    try {
      await ref.update({
        'firstReminder': nextReminder != null ? Timestamp.fromDate(nextReminder) : null,
        'lastTaken': Timestamp.fromDate(now),
      });
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Kayıt güncellenemedi')));
      return;
    }

    // Lokalde de güncelle ki geri sayım anında yenilensin
    setState(() {
      _localDataOverride = Map<String, dynamic>.from(data)
        ..['firstReminder'] = nextReminder != null ? Timestamp.fromDate(nextReminder) : null
        ..['lastTaken'] = Timestamp.fromDate(now);
      // Yeni alarm zamanı ayarlandığında flag'i sıfırla
      _updatingFirstReminder = false;
    });

    try {
      await HistoryService.instance.logIntake(
        medicineId: ref.id,
        medicineName: data['name'] ?? '',
        takenAt: now,
      );
    } catch (_) {
      // geçmiş yazılamasa da ana akışı bozmayalım
    }

    await NotificationService.instance.cancelMedicineReminder(ref.path);
    if (nextReminder != null) {
      try {
        await NotificationService.instance.scheduleMedicineReminder(
          docPath: ref.path,
          medicineName: data['name'] ?? 'İlaç',
          at: nextReminder,
          body: NotificationService.instance.reminderBody(data),
          imageFileName: data['imageFileName'] as String?,
        );
        debugPrint('✅ Yeni bildirim planlandı: ${data['name']} - $nextReminder (Yerel: ${nextReminder.toLocal()})');
      } catch (e) {
        debugPrint('❌ Bildirim planlama hatası: $e');
      }
    }

    if (mounted) {
      // Geri sayımı güncelle
      _updateRemaining();
    }
    messenger.showSnackBar(const SnackBar(content: Text('İlaç alındı olarak işaretlendi')));
  }

  Map<String, dynamic> _currentData() {
    return _localDataOverride ?? widget.doc.data();
  }
}

DateTime? _computeNextReminder(Map<String, dynamic> data) {
  final String regimen = data['regimen'] as String? ?? '';
  final DateTime now = DateTime.now();
  final DateTime? endDate = _extractEndDate(data);
  if (endDate != null && now.isAfter(endDate)) {
    return null;
  }

  if (regimen == 'Saatlik') {
    final intervalHoursValue = data['intervalHours'];

    // Önce firstReminder'ı kontrol et (hem test hem normal mod için)
    DateTime? first = _parseTimestamp(data['firstReminder']);

    // firstReminder varsa ve gelecekteyse direkt döndür
    if (first != null && first.isAfter(now)) {
      if (endDate != null && first.isAfter(endDate)) {
        return null;
      }
      return first;
    }

    // Test modu kontrolü (intervalHours null ise test modu)
    if (intervalHoursValue == null) {
      // Test modu - firstReminder geçmişteyse veya yoksa 1 dakika sonrasına ayarla
      if (first == null || first.isBefore(now) || first.isAtSameMomentAs(now)) {
        final testTime = now.add(const Duration(minutes: 1));
        if (endDate != null && testTime.isAfter(endDate)) {
          return null;
        }
        return testTime;
      }
      // firstReminder gelecekteyse onu kullan
      return first;
    }

    // Normal mod - intervalHours var
    final int interval = intervalHoursValue is int
        ? intervalHoursValue as int
        : int.tryParse('${intervalHoursValue}') ?? 0;
    if (interval <= 0) return null;

    DateTime startDate = now;
    final startTs = data['startDate'];
    if (startTs is Timestamp) {
      final d = startTs.toDate();
      startDate = DateTime(d.year, d.month, d.day, d.hour, d.minute);
    }

    // firstReminder geçmişteyse veya yoksa, bir sonraki alarm zamanını hesapla
    if (first == null || first.isBefore(now) || first.isAtSameMomentAs(now)) {
      // firstReminder'ı startDate veya şimdiki zamandan başlat
      first = first ?? startDate;
      if (first.isBefore(startDate)) {
        first = startDate;
      }

      // lastTaken'ı kontrol et - eğer bir önceki alarma cevap verilmediyse
      // lastTaken'dan itibaren interval ekle, yoksa şimdiki zamandan itibaren interval ekle
      DateTime? lastTaken = _parseTimestamp(data['lastTaken']);
      DateTime baseTime;

      if (lastTaken != null && lastTaken.isAfter(first)) {
        // lastTaken varsa ve first'ten sonraysa, lastTaken'dan itibaren hesapla
        baseTime = lastTaken;
      } else {
        // lastTaken yoksa veya first'ten önceyse, şimdiki zamandan itibaren hesapla
        baseTime = now;
      }

      // first'ten itibaren kaç interval geçtiğini hesapla
      final diff = baseTime.difference(first);
      final totalSeconds = diff.inSeconds;
      final intervalSeconds = interval * 3600;
      final intervalsPassed = (totalSeconds / intervalSeconds).floor();

      // Bir sonraki alarm zamanını hesapla
      DateTime nextAlarm = first.add(Duration(hours: interval * (intervalsPassed + 1)));

      // Eğer nextAlarm geçmişteyse veya şimdiye eşitse, bir sonraki interval'i ekle
      if (!nextAlarm.isAfter(now)) {
        nextAlarm = nextAlarm.add(Duration(hours: interval));
      }

      if (endDate != null && nextAlarm.isAfter(endDate)) {
        return null;
      }
      return nextAlarm;
    }

    if (endDate != null && first.isAfter(endDate)) {
      return null;
    }
    return first;
  }

  if (regimen == 'Öğünlere Göre') {
    final startTs = data['startDate'];
    DateTime startDate = now;
    if (startTs is Timestamp) {
      final d = startTs.toDate();
      startDate = DateTime(d.year, d.month, d.day);
    }
    final rawTimes = data['mealTimes'];
    if (rawTimes is List) {
      final times = rawTimes.map((e) => e.toString()).toList();
      return _findNextMealReminder(times, startDate, now, endDate);
    }
  }

  return null;
}

DateTime? _findNextMealReminder(
  List<String> times,
  DateTime startDate,
  DateTime now,
  DateTime? endDate,
) {
  if (times.isEmpty) return null;
  final DateTime base = DateTime(startDate.year, startDate.month, startDate.day);
  final DateTime today = DateTime(now.year, now.month, now.day);
  int offsetStart = today.difference(base).inDays;
  if (offsetStart < 0) offsetStart = 0;
  final DateTime? endLimit = endDate;
  DateTime? candidate;

  for (int offset = offsetStart; offset < offsetStart + 7; offset++) {
    final DateTime day = base.add(Duration(days: offset));
    for (final entry in times) {
      final parsed = _parseTime(entry);
      if (parsed == null) continue;
      final DateTime dt = DateTime(day.year, day.month, day.day, parsed.hour, parsed.minute);
      if (dt.isAfter(now) && (endLimit == null || !dt.isAfter(endLimit))) {
        if (candidate == null || dt.isBefore(candidate)) {
          candidate = dt;
        }
      }
    }
    if (candidate != null) break;
  }

  return candidate;
}

TimeOfDay? _parseTime(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatDuration(Duration duration, BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  final int days = duration.inDays;
  final int hours = duration.inHours % 24;
  final int minutes = duration.inMinutes % 60;
  final int seconds = duration.inSeconds % 60;

  if (days > 0) {
    return '$days ${localizations.days} $hours ${localizations.hours} $minutes ${localizations.minutes}';
  }
  if (hours > 0) {
    return '$hours ${localizations.hours} $minutes ${localizations.minutes}';
  }
  if (minutes > 0) {
    return '$minutes ${localizations.minutes} ${seconds.toString().padLeft(2, '0')} ${localizations.seconds}';
  }
  return '$seconds ${localizations.seconds}';
}

DateTime? _extractEndDate(Map<String, dynamic> data) {
  final endTs = data['endDate'];
  if (endTs is Timestamp) {
    final d = endTs.toDate();
    return DateTime(d.year, d.month, d.day, 23, 59, 59);
  }
  return null;
}

bool _isExpired(Map<String, dynamic> data) {
  final DateTime now = DateTime.now();
  final DateTime? end = _extractEndDate(data);
  if (end == null) return false;
  return now.isAfter(end);
}

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return null;
}
