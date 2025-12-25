import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../l10n/app_localizations.dart';
import 'all_history_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _hideBefore; // persisted per-user threshold

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1E66A6);
    final User? user = FirebaseAuth.instance.currentUser;
    final localizations = AppLocalizations.of(context);

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(localizations?.loginRequired ?? 'Login required')),
      );
    }

    final historyService = HistoryService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.historyTitle ?? 'History'),
        centerTitle: true,
        actions: [
          PopupMenuButton<_HistoryMenu>(
            tooltip: localizations?.options ?? 'Options',
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _HistoryMenu.clear,
                child: ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: Text(localizations?.clear ?? 'Clear'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: _HistoryMenu.viewAll,
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(localizations?.viewAll ?? 'View All History'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case _HistoryMenu.clear:
                  final now = DateTime.now();
                  historyService.setHistoryHiddenBefore(now);
                  setState(() => _hideBefore = now);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations!.historyCleared)),
                  );
                  break;
                case _HistoryMenu.viewAll:
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AllHistoryScreen()),
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<DateTime?>(
          stream: historyService.hiddenBeforeStream(),
          builder: (context, hideSnapshot) {
            if (hideSnapshot.hasError) {
              return Center(child: Text(localizations!.cannotLoadHistory));
            }
            if (hideSnapshot.connectionState == ConnectionState.waiting && _hideBefore == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final remoteHideBefore = hideSnapshot.data;
            final effectiveHideBefore = remoteHideBefore ?? _hideBefore;
            _hideBefore = effectiveHideBefore;

            return StreamBuilder<List<HistoryEntry>>(
              stream: historyService.watchHistory(hideBefore: effectiveHideBefore),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(localizations!.historyLoadFailed));
                }
                if (snapshot.connectionState == ConnectionState.waiting && (snapshot.data == null)) {
                  return const Center(child: CircularProgressIndicator());
                }

                final entries = snapshot.data ?? const <HistoryEntry>[];
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 96, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          localizations!.noHistoryYet,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            localizations!.historyDataKeptMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: entries.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [primaryBlue.withOpacity(0.12), primaryBlue.withOpacity(0.04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: primaryBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizations!.historyInfoMessage,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final entry = entries[index - 1];
                    final displayDate = _formatDateTime(entry.takenAt);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check, color: Colors.green),
                        ),
                        title: Text(entry.medicineName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('Alındı: $displayDate'),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final String day = dateTime.day.toString().padLeft(2, '0');
  final String month = dateTime.month.toString().padLeft(2, '0');
  final String year = dateTime.year.toString();
  final String hour = dateTime.hour.toString().padLeft(2, '0');
  final String minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day.$month.$year • $hour:$minute';
}

enum _HistoryMenu { clear, viewAll }
