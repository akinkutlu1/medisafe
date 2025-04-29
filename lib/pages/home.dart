import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        backgroundColor: Colors.pink.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugünkü İlaçlarınız',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.medication, color: Colors.pink),
                title: const Text('Parol - 08:00'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.thumb_up_alt_outlined, color: Colors.green),
                    SizedBox(width: 10),
                    Icon(Icons.thumb_down_alt_outlined, color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.medication, color: Colors.pink),
                title: const Text('Vitamin C - 12:00'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.thumb_up_alt_outlined, color: Colors.green),
                    SizedBox(width: 10),
                    Icon(Icons.thumb_down_alt_outlined, color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Genel Durum',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade300,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoCard('Toplam İlaç', '6'),
                _infoCard('Alınan', '4'),
                _infoCard('Kalan', '2'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String count) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: SizedBox(
        width: 100,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
