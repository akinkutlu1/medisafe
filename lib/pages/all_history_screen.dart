import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../l10n/app_localizations.dart';

class AllHistoryScreen extends StatelessWidget {
  const AllHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text(localizations?.allHistoryTitle ?? 'All History'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<HistoryEntry>>(
          stream: historyService.watchAllHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(localizations?.historyLoadFailed ?? 'Failed to load history'));
            }
            if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data ?? const <HistoryEntry>[];
            if (entries.isEmpty) {
              return Center(child: Text(localizations?.historyNotFound ?? 'History not found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final String display = _formatDateTime(entry.takenAt);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(entry.medicineName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(display),
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                  ),
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




