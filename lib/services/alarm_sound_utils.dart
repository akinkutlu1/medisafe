import 'dart:convert';

import 'package:flutter/services.dart';

const String alarmDefaultKey = 'default';
const String alarmDefaultAsset = 'assets/sounds/digital-alarm-02-151919.mp3';

Future<Map<String, String>> loadAlarmSounds() async {
  final Map<String, String> result = {alarmDefaultKey: 'Varsayılan'};
  try {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;
    for (final entry in manifestMap.keys) {
      if (entry.startsWith('assets/sounds/')) {
        result[entry] = _humanizeFileName(entry.split('/').last);
      }
    }
  } catch (_) {}
  return result;
}

String alarmSoundLabel(String? key, {Map<String, String>? available}) {
  if (key == null || key.isEmpty || key == alarmDefaultKey) {
    return 'Varsayılan';
  }
  if (available != null && available.containsKey(key)) {
    return available[key]!;
  }
  return _humanizeFileName(key.split('/').last);
}

String alarmSoundAssetFromKey(String? key) {
  if (key == null || key == alarmDefaultKey) {
    return alarmDefaultAsset;
  }
  return key;
}

String _humanizeFileName(String fileName) {
  final String noExtension = fileName.split('.').first;
  final words = noExtension
      .split(RegExp('[-_]'))
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase());
  return words.join(' ');
}



