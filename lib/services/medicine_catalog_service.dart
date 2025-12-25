import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

class MedicineSuggestion {
  final String name;
  final String? imageFileName; // null => default image

  MedicineSuggestion({required this.name, this.imageFileName});
}

class MedicineCatalogService {
  MedicineCatalogService._();
  static final MedicineCatalogService instance = MedicineCatalogService._();

  bool _loaded = false;
  final List<MedicineSuggestion> _items = [];

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    // Dosya: assets/ilacVeriSeti.xlsx
    // Sütunlar: ID | Name | Amount | Quantity | Image
    final ByteData data = await rootBundle.load('assets/ilacVeriSeti.xlsx');
    final bytes = data.buffer.asUint8List();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      _loaded = true;
      return;
    }

    final String firstTableKey = excel.tables.keys.first;
    final table = excel.tables[firstTableKey]!;

    // Satır 0: başlıklar
    for (int rowIndex = 1; rowIndex < table.maxRows; rowIndex++) {
      final row = table.row(rowIndex);
      if (row.length < 2) continue;
      final nameCell = row[1]; // Name sütunu
      if (nameCell == null || nameCell.value == null) continue;
      final String name = nameCell.value.toString().trim();
      if (name.isEmpty) continue;

      String? imageFileName;
      if (row.length > 4) {
        final imageCell = row[4];
        if (imageCell != null && imageCell.value != null) {
          final v = imageCell.value.toString().trim();
          if (v.isNotEmpty) {
            imageFileName = v;
          }
        }
      }

      _items.add(
        MedicineSuggestion(
          name: name,
          imageFileName: imageFileName,
        ),
      );
    }

    _loaded = true;
  }

  /// Kullanıcı yazdıkça öneri listesi (ilk 10 sonuç).
  Future<List<MedicineSuggestion>> search(String query) async {
    await _ensureLoaded();
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];
    final List<MedicineSuggestion> result = [];
    for (final item in _items) {
      if (item.name.toLowerCase().contains(q)) {
        result.add(item);
        if (result.length >= 10) break;
      }
    }
    return result;
  }

  /// OCR metnindeki kelimelere göre yakın ilaçları sıralar.
  /// Metni kelimelere ayırır, her kelime için eşleşme skoru hesaplar.
  Future<List<MedicineSuggestion>> searchByWords(String text) async {
    await _ensureLoaded();
    final t = text.trim().toLowerCase();
    if (t.length < 2) return [];

    // Metni kelimelere ayır (boşluk, nokta, virgül, vb. karakterlerle)
    final words = t
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toSet()
        .toList();

    if (words.isEmpty) return [];

    // Her ilaç için skor hesapla
    final Map<MedicineSuggestion, int> scoredItems = {};
    
    for (final item in _items) {
      final itemName = item.name.toLowerCase();
      int score = 0;
      
      // Her kelime için eşleşme kontrolü
      for (final word in words) {
        if (itemName.contains(word)) {
          // Kelime uzunluğuna göre skor ver (uzun kelimeler daha önemli)
          score += word.length;
          
          // Tam kelime eşleşmesi ekstra puan
          final itemWords = itemName.split(RegExp(r'\s+'));
          if (itemWords.contains(word)) {
            score += 5;
          }
        }
      }
      
      if (score > 0) {
        scoredItems[item] = score;
      }
    }
    
    // Skora göre sırala (yüksekten düşüğe)
    final sortedEntries = scoredItems.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // İlk 10 sonucu döndür
    return sortedEntries.take(10).map((e) => e.key).toList();
  }

  /// Tam isimle eşleşen ilacın resmini döndürür.
  Future<String?> imageForName(String name) async {
    await _ensureLoaded();
    final q = name.trim().toLowerCase();
    for (final item in _items) {
      if (item.name.toLowerCase() == q) {
        return item.imageFileName;
      }
    }
    return null;
  }

  /// Paket üzerindeki metinden en iyi eşleşen ilacı bulmaya çalışır
  /// (metin içinde ilacın tam adı geçiyorsa).
  Future<MedicineSuggestion?> detectFromText(String text) async {
    await _ensureLoaded();
    final t = text.toLowerCase();
    MedicineSuggestion? best;
    int bestLength = 0;
    for (final item in _items) {
      final n = item.name.toLowerCase();
      if (t.contains(n) && n.length > bestLength) {
        best = item;
        bestLength = n.length;
      }
    }
    return best;
  }
}


