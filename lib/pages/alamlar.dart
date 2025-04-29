import 'package:flutter/material.dart';
import '../data/gecmis.dart'; // Geçmiş listesi

class AlamlarPage extends StatefulWidget {
  const AlamlarPage({super.key});

  @override
  State<AlamlarPage> createState() => _AlamlarPageState();
}

class _AlamlarPageState extends State<AlamlarPage> {
  List<Map<String, String>> alarmlar = [
    {'ilac': 'Parol', 'saat': '08:00'},
    {'ilac': 'Vitamin C', 'saat': '12:00'},
    {'ilac': 'Demir Takviyesi', 'saat': '20:00'},
  ];

  // Alarm kaydını geçmişe ekleme
  void ilaciAldim(int index) {
    final alarm = alarmlar[index];

    gecmisAlarmlar.add({
      'ilac': alarm['ilac']!,
      'tarih': DateTime.now().toString().substring(0, 10),
      'saat': alarm['saat']!,
    });

    setState(() {
      alarmlar.removeAt(index); // Silindiği zaman alarmlar listesinde kaybolur
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İlaç geçmişe kaydedildi!')),
    );
  }

  // Alarm ekleme
  void alarmEkle() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController ilacController = TextEditingController();
        final TextEditingController saatController = TextEditingController();

        return AlertDialog(
          title: const Text('Yeni Alarm Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ilacController,
                decoration: const InputDecoration(hintText: 'İlaç adı'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: saatController,
                decoration:
                    const InputDecoration(hintText: 'Saat (örn: 08:00)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (ilacController.text.isNotEmpty &&
                    saatController.text.isNotEmpty) {
                  setState(() {
                    alarmlar.add({
                      'ilac': ilacController.text,
                      'saat': saatController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  // Alarm silme
  void ilaciSil(int index) {
    setState(() {
      alarmlar.removeAt(index); // Alarm silindiği zaman listeden kaybolur
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İlaç silindi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Alarmlar'),
        backgroundColor: Colors.pink.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: alarmEkle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: alarmlar.isEmpty
            ? const Center(
                child: Text(
                  'Alarm bulunmamaktadır.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: alarmlar.length,
                itemBuilder: (context, index) {
                  final alarm = alarmlar[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.alarm, color: Colors.pink),
                            title: Text(
                              alarm['ilac']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Saat: ${alarm['saat']}'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () => ilaciAldim(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'İlacı Aldım',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => ilaciSil(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Sil',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
