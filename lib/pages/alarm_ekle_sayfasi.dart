import 'package:flutter/material.dart';
import 'alarm.dart';

class AlarmEkleSayfasi extends StatefulWidget {
  const AlarmEkleSayfasi({super.key});

  @override
  State<AlarmEkleSayfasi> createState() => _AlarmEkleSayfasiState();
}

class _AlarmEkleSayfasiState extends State<AlarmEkleSayfasi> {
  final TextEditingController _ilacAdiController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _saatSec(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _alarmKaydet() {
    String ilacAdi = _ilacAdiController.text.trim();
    if (ilacAdi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlaç adını giriniz!')),
      );
      return;
    }

    final alarm = Alarm(
      ilacAdi: ilacAdi,
      saat: _selectedTime.format(context),
    );

    Navigator.pop(context, alarm); // ALARM NESNESİNİ GERİ DÖNÜYORUZ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink.shade400,
        title: const Text('Yeni Alarm Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _ilacAdiController,
              decoration: InputDecoration(
                labelText: 'İlaç Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Seçilen Saat: ${_selectedTime.format(context)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _saatSec(context),
                  child: const Text('Saat Seç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade300,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _alarmKaydet,
                child: const Text('Kaydet', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
