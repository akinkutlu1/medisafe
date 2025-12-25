import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/alarm_sound_utils.dart';

class AlarmSoundScreen extends StatefulWidget {
  const AlarmSoundScreen({super.key});

  @override
  State<AlarmSoundScreen> createState() => _AlarmSoundScreenState();
}

class _AlarmSoundScreenState extends State<AlarmSoundScreen> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentSelection; // asset path or 'default'
  bool _loading = true;
  Map<String, String> _items = const {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final String? saved = user == null
          ? null
          : (await FirebaseFirestore.instance.collection('users').doc(user.uid).get())
              .data()?['alarmSound'] as String?;
      final Map<String, String> items = await loadAlarmSounds();
      setState(() {
        _items = items;
        _currentSelection = saved ?? alarmDefaultKey;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _preview(String key) async {
    try {
      await _player.stop();
      final assetPath = alarmSoundAssetFromKey(key);
      if (assetPath.isEmpty) return;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {}
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {'alarmSound': _currentSelection ?? alarmDefaultKey},
            SetOptions(merge: true),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm sesi'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final key = _items.keys.elementAt(index);
                final label = _items[key] ?? alarmSoundLabel(key);
                final bool selected = key == _currentSelection;
                return Card(
                  child: ListTile(
                    leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.grey),
                    title: Text(label),
                    subtitle: key == 'default' ? const Text('Sistem varsayılanı') : Text(key),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _preview(key),
                    ),
                    onTap: () async {
                      setState(() => _currentSelection = key);
                      await _preview(key);
                    },
                  ),
                );
              },
            ),
    );
  }
}



