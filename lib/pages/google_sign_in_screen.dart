import 'package:flutter/material.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1E66A6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: primaryBlue,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Continue with Google!',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'This is a placeholder for Google Sign-In.\nWe\'ll integrate Firebase here later.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/google.png', width: 20, height: 20),
                          const SizedBox(width: 8),
                          const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Text('Choose an account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primaryBlue)),
                      const SizedBox(height: 8),
                      _accountTile('Sana Nassani', 'sana.nassani3@gmail.com'),
                      _accountTile('SANA NASSANI', 'sana.nassani@std.hku.edu.tr'),
                      _accountTile('Use another account', ''),
                      const SizedBox(height: 16),
                      Text(
                        'To continue, Google will share your name, email address, language preference, and profile picture with the app.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Sign-In will be implemented with Firebase.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountTile(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Text(title.isNotEmpty ? title[0] : '+', style: const TextStyle(color: Colors.black87)),
      ),
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: () {},
    );
  }
}




