import 'package:flutter/material.dart';
import '../data/gecmis.dart';

class GecmisPage extends StatefulWidget {
  const GecmisPage({super.key});

  @override
  State<GecmisPage> createState() => _GecmisPageState();
}

class _GecmisPageState extends State<GecmisPage> {
  void alarmSil(int index) {
    setState(() {
      gecmisAlarmlar.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Geçmişten silindi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Geçmiş'),
        backgroundColor: Colors.pink.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: gecmisAlarmlar.isEmpty
            ? const Center(
                child: Text(
                  'Geçmiş kaydı yok.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: gecmisAlarmlar.length,
                itemBuilder: (context, index) {
                  final alarm = gecmisAlarmlar[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.pink),
                      title: Text(
                        alarm['ilac']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Tarih: ${alarm['tarih']}, Saat: ${alarm['saat']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => alarmSil(index),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
