import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key, required this.medicineDocPath, required this.medicineName});

  final String medicineDocPath; // users/{uid}/medicines/{id}
  final String medicineName;

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  _AlarmAction? _actionInProgress;

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1E66A6);

    // Widget tree'yi güvenli hale getir
    return PopScope(
      canPop: false, // Geri tuşu ile kapatmayı engelle
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Resim widget'ını güvenli hale getir
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _AlarmImage(docPath: widget.medicineDocPath),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.medicineName.isNotEmpty ? widget.medicineName : AppLocalizations.of(context)!.medicines,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaryBlue),
                    ),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.didYouTakeMedicine, style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _actionInProgress == null ? () => _completeIntake(_AlarmAction.taken) : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: _actionInProgress == _AlarmAction.taken
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.processing, style: const TextStyle(color: Colors.white)),
                              ],
                            )
                          : Text(AppLocalizations.of(context)!.tookMyMedicine),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _actionInProgress == null ? _snooze : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      icon: _actionInProgress == _AlarmAction.snooze
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.snooze),
                      label: Text(AppLocalizations.of(context)!.snooze30Min),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _actionInProgress == null ? () => _completeIntake(_AlarmAction.ignore) : null,
                      child: _actionInProgress == _AlarmAction.ignore
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(AppLocalizations.of(context)!.ignoreMarkTaken),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.snoozeIgnoreExplanation,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              );
            } catch (e) {
              debugPrint('❌ Alarm ekranı build hatası: $e');
              // Hata durumunda basit bir ekran göster
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      widget.medicineName.isNotEmpty ? widget.medicineName : 'İlaç',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaryBlue),
                    ),
                    const SizedBox(height: 8),
                    const Text('İlacı aldınız mı?', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _actionInProgress == null ? () => _completeIntake(_AlarmAction.taken) : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: _actionInProgress == _AlarmAction.taken
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('İlacımı Aldım'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _actionInProgress == null ? _snooze : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      icon: _actionInProgress == _AlarmAction.snooze
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.snooze),
                      label: const Text('Ertele (30 dk)'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _actionInProgress == null ? () => _completeIntake(_AlarmAction.ignore) : null,
                      child: _actionInProgress == _AlarmAction.ignore
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Yoksay (Aldı say)'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      ),
    );
  }

  Future<void> _completeIntake(_AlarmAction action) async {
    debugPrint('🔧 _completeIntake started with action: $action');
    if (_actionInProgress != null) {
      debugPrint('❌ Action already in progress: $_actionInProgress');
      return;
    }

    if (!mounted) {
      debugPrint('❌ Widget not mounted');
      return;
    }

    // Show loading state briefly
    setState(() => _actionInProgress = action);

    // Navigate immediately for better UX
    debugPrint('🚪 Immediate navigation for better UX...');
    if (mounted) {
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          debugPrint('✅ Successfully popped immediately');
        } else {
          debugPrint('⚠️ Cannot pop, using popUntil');
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (navError) {
        debugPrint('❌ Immediate navigation error: $navError');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }

    // Handle operations in background (fire-and-forget)
    _handleBackgroundOperations(action);
  }

  void _handleBackgroundOperations(_AlarmAction action) async {
    debugPrint('🔄 Starting background operations...');
    try {
      // Firestore bağlantısını kontrol et
      final docRef = FirebaseFirestore.instance.doc(widget.medicineDocPath).withConverter<Map<String, dynamic>>(
            fromFirestore: (s, _) => s.data() ?? <String, dynamic>{},
            toFirestore: (v, _) => v,
          );

      debugPrint('🔍 Fetching document from Firestore in background...');
      final snapshot = await docRef.get().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('❌ Background Firestore timeout');
          throw TimeoutException('Background operation timeout', const Duration(seconds: 5));
        },
      );

      if (!snapshot.exists) {
        debugPrint('❌ Document does not exist in background');
        return;
      }

      final data = snapshot.data() ?? {};
      final DateTime now = DateTime.now();
      DateTime? nextReminder;
      final String regimen = data['regimen'] ?? '';

      if (regimen == 'Saatlik') {
        final dynamic intervalRaw = data['intervalHours'];
        if (intervalRaw == null) {
          nextReminder = now.add(const Duration(minutes: 1));
        } else {
          final int interval = intervalRaw is int ? intervalRaw : int.tryParse('$intervalRaw') ?? 0;
          if (interval > 0) {
            nextReminder = now.add(Duration(hours: interval));
          }
        }

        final DateTime? end = _extractEndDate(data);
        if (end != null && nextReminder != null && nextReminder.isAfter(end)) {
          nextReminder = null;
        }
      } else {
        final rawTimes = data['mealTimes'];
        if (rawTimes is List) {
          final times = rawTimes.map((e) => e.toString()).toList();
          final DateTime start = _parseTimestamp(data['startDate']) ?? now;
          final DateTime? end = _extractEndDate(data);
          nextReminder = _findNextMealReminder(times, start, now, end);
        }
      }

      // Update Firestore in background
      debugPrint('💾 Updating Firestore document in background...');
      await docRef.update({
        'firstReminder': nextReminder != null ? Timestamp.fromDate(nextReminder) : null,
        'lastTaken': Timestamp.fromDate(now),
      }).timeout(const Duration(seconds: 5));

      // Handle notifications in background
      debugPrint('📱 Handling notifications in background...');
      try {
        await NotificationService.instance.cancelMedicineReminder(docRef.path);
        if (nextReminder != null) {
          await NotificationService.instance.scheduleMedicineReminder(
            docPath: docRef.path,
            medicineName: data['name'] ?? widget.medicineName,
            at: nextReminder,
            body: NotificationService.instance.reminderBody(data),
            imageFileName: data['imageFileName'] as String?,
          ).timeout(const Duration(seconds: 5));
        }
        debugPrint('✅ Background notifications updated');
      } catch (e) {
        debugPrint('⚠️ Background notification error: $e');
      }

      // Log to history in background
      debugPrint('📝 Logging to history in background...');
      try {
        await HistoryService.instance.logIntake(
          medicineId: docRef.id,
          medicineName: data['name'] ?? '',
          takenAt: now,
        ).timeout(const Duration(seconds: 5));
        debugPrint('✅ Background history logged');
      } catch (e) {
        debugPrint('⚠️ Background history error: $e');
      }

      // Clear pending alarms
      NotificationService.instance.clearPendingAlarm(widget.medicineDocPath);
      debugPrint('✅ Background operations completed successfully');

    } catch (e) {
      debugPrint('❌ Background operation error: $e');
      // Don't show UI errors since user has already navigated away
    }
  }

  Future<void> _snooze() async {
    debugPrint('⏰ _snooze started');
    if (_actionInProgress != null) {
      debugPrint('❌ Action already in progress during snooze: $_actionInProgress');
      return;
    }

    if (!mounted) {
      debugPrint('❌ Widget not mounted during snooze');
      return;
    }

    // Show loading state briefly
    setState(() => _actionInProgress = _AlarmAction.snooze);

    // Navigate immediately for better UX
    debugPrint('🚪 Immediate snooze navigation for better UX...');
    if (mounted) {
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          debugPrint('✅ Successfully popped from snooze immediately');
        } else {
          debugPrint('⚠️ Cannot pop from snooze, using popUntil');
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (navError) {
        debugPrint('❌ Immediate snooze navigation error: $navError');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }

    // Handle snooze operations in background
    _handleSnoozeBackgroundOperations();
  }

  void _handleSnoozeBackgroundOperations() async {
    debugPrint('⏰ Starting background snooze operations...');
    try {
      final docRef = FirebaseFirestore.instance.doc(widget.medicineDocPath).withConverter<Map<String, dynamic>>(
            fromFirestore: (s, _) => s.data() ?? <String, dynamic>{},
            toFirestore: (v, _) => v,
          );

      final snapshot = await docRef.get().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('❌ Background snooze Firestore timeout');
          throw TimeoutException('Background snooze timeout', const Duration(seconds: 5));
        },
      );

      if (!snapshot.exists) {
        debugPrint('❌ Document does not exist for snooze background');
        return;
      }

      final data = snapshot.data() ?? {};
      final DateTime snoozeTime = DateTime.now().add(const Duration(minutes: 30));

      // Update Firestore in background
      await docRef.update({
        'firstReminder': Timestamp.fromDate(snoozeTime),
      }).timeout(const Duration(seconds: 5));

      // Handle notifications in background
      try {
        await NotificationService.instance.cancelMedicineReminder(docRef.path);
        await NotificationService.instance.scheduleMedicineReminder(
          docPath: docRef.path,
          medicineName: data['name'] ?? widget.medicineName,
          at: snoozeTime,
          body: NotificationService.instance.reminderBody(data),
          imageFileName: data['imageFileName'] as String?,
        ).timeout(const Duration(seconds: 5));
        debugPrint('✅ Background snooze notifications updated');
      } catch (e) {
        debugPrint('⚠️ Background snooze notification error: $e');
      }

      // Clear pending alarms
      NotificationService.instance.clearPendingAlarm(widget.medicineDocPath);
      debugPrint('✅ Background snooze operations completed successfully');

    } catch (e) {
      debugPrint('❌ Background snooze operation error: $e');
      // Don't show UI errors since user has already navigated away
    }
  }
}

class _AlarmImage extends StatelessWidget {
  const _AlarmImage({required this.docPath});

  final String docPath;

  @override
  Widget build(BuildContext context) {
    // Maksimum boyut - ekran genişliğinin %60'ı
    final maxSize = MediaQuery.of(context).size.width * 0.6;

    // Path boşsa direkt default resim göster
    if (docPath.isEmpty) {
      return SizedBox(
        width: maxSize,
        height: maxSize,
        child: Image.asset(
          'assets/images/pill.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/reminder.png',
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.doc(docPath).get().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Timeout durumunda exception fırlat, builder'da handle edilecek
          throw TimeoutException('Firestore bağlantı zaman aşımı');
        },
      ),
      builder: (context, snapshot) {
        // Maksimum boyut - ekran genişliğinin %60'ı
        final maxSize = MediaQuery.of(context).size.width * 0.6;

        // Hata durumunda veya timeout durumunda default resim göster
        if (snapshot.hasError) {
          debugPrint('⚠️ Alarm resmi yüklenirken hata: ${snapshot.error}');
          return SizedBox(
            width: maxSize,
            height: maxSize,
            child: Image.asset(
              'assets/images/pill.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/reminder.png',
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        // Yükleniyor durumu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: maxSize,
            height: maxSize,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        String? imageFileName;
        if (snapshot.hasData && snapshot.data!.exists) {
          try {
            imageFileName = snapshot.data!.data()?['imageFileName'] as String?;
          } catch (e) {
            debugPrint('⚠️ ImageFileName okuma hatası: $e');
          }
        }

        if (imageFileName == null || imageFileName.isEmpty) {
          return SizedBox(
            width: maxSize,
            height: maxSize,
            child: Image.asset(
              'assets/images/pill.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/reminder.png',
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        return SizedBox(
          width: maxSize,
          height: maxSize,
          child: Image.asset(
            'assets/medimages/$imageFileName',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/pill.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/reminder.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

DateTime? _extractEndDate(Map<String, dynamic> data) {
  final endTs = data['endDate'];
  if (endTs is Timestamp) {
    final d = endTs.toDate();
    return DateTime(d.year, d.month, d.day, 23, 59, 59);
  }
  return null;
}

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  return null;
}

TimeOfDay? _parseTime(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
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
        if (candidate == null || dt.isBefore(candidate)) candidate = dt;
      }
    }
    if (candidate != null) break;
  }
  return candidate;
}

enum _AlarmAction { taken, ignore, snooze }
