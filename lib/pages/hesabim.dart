import 'package:flutter/material.dart';

bool isLoggedIn = true; // Kullanıcı giriş durumu

class HesabimPage extends StatelessWidget {
  const HesabimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        backgroundColor: Colors.pink.shade400,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil fotoğrafı ve ismi
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://www.example.com/profile.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Ahmet Yılmaz', // Kullanıcı adı
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'ahmet.yilmaz@example.com', // Kullanıcı e-posta adresi
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Kullanıcı bilgileri
            _buildInfoCard('Kullanıcı Adı', 'Ahmet Yılmaz'),
            _buildInfoCard('E-posta', 'ahmet.yilmaz@example.com'),
            _buildInfoCard('Telefon', '+90 555 123 4567'),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Çıkış yapma işlemi
                isLoggedIn = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Çıkış yapıldı!')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kullanıcı bilgilerini gösterecek bir widget
  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
