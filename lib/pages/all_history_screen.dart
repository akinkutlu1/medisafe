import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/history_service.dart';

class AllHistoryScreen extends StatelessWidget {
  const AllHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Giriş yapılmalı')),
      );
    }

    final historyService = HistoryService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Geçmiş'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<HistoryEntry>>(
          stream: historyService.watchAllHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Geçmiş yüklenemedi'));
            }
            if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data ?? const <HistoryEntry>[];
            if (entries.isEmpty) {
              return const Center(child: Text('Geçmiş bulunamadı'));
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




