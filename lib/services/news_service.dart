import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String source;
  final String? description;
  final String? url;
  final String? publishedAt;

  NewsArticle({
    required this.title,
    required this.source,
    this.description,
    this.url,
    this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: NewsService._decodeHtmlEntities(
        (json['title'] ?? '').toString(),
      ),
      source: NewsService._decodeHtmlEntities(
        (json['source']?['name'] ?? 'Bilinmeyen Kaynak').toString(),
      ),
      description: json['description'] != null
          ? NewsService._decodeHtmlEntities(json['description'].toString())
          : null,
      url: json['url'],
      publishedAt: json['publishedAt'],
    );
  }
}

class NewsService {
  // NewsAPI ücretsiz API key'si (development için)
  // Üretim ortamında kendi API key'inizi kullanın: https://newsapi.org/register
  // Veya boş bırakırsanız RSS feed'lerden haber çekilir
  static const String apiKey = '';
  static const String baseUrl = 'https://newsapi.org/v2';

  /// Sağlık haberlerini çeker (en güncel 3 haber)
  /// Önce NewsAPI'yi dener, başarısız olursa RSS feed'lerden çeker
  static Future<List<NewsArticle>> getHealthNews({int limit = 3}) async {
    // Eğer API key varsa NewsAPI'yi dene
    if (apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE') {
      try {
        final news = await _fetchFromNewsAPI(limit: limit);
        if (news.isNotEmpty) return news;
      } catch (e) {
        print('NewsAPI hatası: $e');
      }
    }

    // NewsAPI çalışmazsa RSS feed'lerden çek
    try {
      final news = await _fetchFromRSSFeeds(limit: limit);
      if (news.isNotEmpty) return news;
    } catch (e) {
      print('RSS feed hatası: $e');
    }

    // Her ikisi de başarısız olursa fallback haberler
    return _getFallbackNews();
  }

  /// NewsAPI'den haber çeker
  static Future<List<NewsArticle>> _fetchFromNewsAPI({int limit = 3}) async {
    final url = Uri.parse(
      '$baseUrl/top-headlines?country=tr&category=health&pageSize=$limit&apiKey=$apiKey',
    );

    final response = await http.get(
      url,
      headers: {'Accept-Charset': 'utf-8'},
    );

    if (response.statusCode == 200) {
      // UTF-8 olarak decode et
      final responseBody = utf8.decode(response.bodyBytes);
      final data = json.decode(responseBody);
      
      if (data['status'] == 'ok' && data['articles'] != null) {
        final List<dynamic> articles = data['articles'];
        
        return articles
            .take(limit)
            .map((article) {
              // Her article'ın title ve description'ını decode et
              final decodedArticle = Map<String, dynamic>.from(article);
              if (decodedArticle['title'] != null) {
                decodedArticle['title'] = _decodeHtmlEntities(
                  decodedArticle['title'].toString(),
                );
              }
              if (decodedArticle['description'] != null) {
                decodedArticle['description'] = _decodeHtmlEntities(
                  decodedArticle['description'].toString(),
                );
              }
              return NewsArticle.fromJson(decodedArticle);
            })
            .toList();
      }
    }

    return [];
  }

  /// RSS feed'lerden haber çeker (Türkçe sağlık haberleri)
  static Future<List<NewsArticle>> _fetchFromRSSFeeds({int limit = 3}) async {
    // Türkçe sağlık haber sitelerinin RSS feed'leri
    final rssFeeds = [
      'https://www.ntv.com.tr/saglik.rss',
      'https://www.haberturk.com/rss/kategori/saglik.xml',
      'https://www.sozcu.com.tr/kategori/saglik/feed/',
    ];

    List<NewsArticle> allNews = [];

    for (final feedUrl in rssFeeds) {
      try {
        final response = await http.get(
          Uri.parse(feedUrl),
          headers: {'Accept-Charset': 'utf-8'},
        ).timeout(
          const Duration(seconds: 5),
        );

        if (response.statusCode == 200) {
          // Response'u UTF-8 olarak decode et
          String xmlContent = '';
          try {
            // Önce encoding'i kontrol et
            final charset = _getCharsetFromResponse(response);
            if (charset != null && charset.toLowerCase() != 'utf-8') {
              xmlContent = utf8.decode(
                response.bodyBytes,
                allowMalformed: true,
              );
            } else {
              xmlContent = utf8.decode(response.bodyBytes);
            }
          } catch (e) {
            // UTF-8 decode başarısız olursa latin1 dene
            xmlContent = latin1.decode(response.bodyBytes);
          }

          final news = _parseRSSFeed(xmlContent);
          allNews.addAll(news);
          
          if (allNews.length >= limit) break;
        }
      } catch (e) {
        continue; // Bu feed'den haber çekilemedi, diğerini dene
      }
    }

    // En güncel haberleri döndür (limit'e kadar)
    return allNews.take(limit).toList();
  }

  /// Response header'dan charset'i bulur
  static String? _getCharsetFromResponse(http.Response response) {
    final contentType = response.headers['content-type'];
    if (contentType != null) {
      final charsetMatch = RegExp(r'charset=([^;]+)').firstMatch(contentType);
      if (charsetMatch != null) {
        return charsetMatch.group(1);
      }
    }
    return null;
  }

  /// RSS XML'i parse eder
  static List<NewsArticle> _parseRSSFeed(String xmlContent) {
    List<NewsArticle> articles = [];
    
    try {
      // Basit RSS parsing (title ve description çıkarır)
      final itemMatches = RegExp(r'<item>(.*?)</item>', dotAll: true)
          .allMatches(xmlContent);
      
      for (final match in itemMatches) {
        final itemContent = match.group(1) ?? '';
        
        // CDATA olan title'ları önce dene
        var titleMatch = RegExp(r'<title><!\[CDATA\[(.*?)\]\]></title>', dotAll: true)
            .firstMatch(itemContent);
        
        // CDATA yoksa normal title'ı dene
        titleMatch ??= RegExp(r'<title>(.*?)</title>', dotAll: true)
            .firstMatch(itemContent);
        
        // CDATA olan description'ları önce dene
        var descriptionMatch = RegExp(
                r'<description><!\[CDATA\[(.*?)\]\]></description>', dotAll: true)
            .firstMatch(itemContent);
        
        // CDATA yoksa normal description'ı dene
        descriptionMatch ??= RegExp(r'<description>(.*?)</description>', dotAll: true)
            .firstMatch(itemContent);
        
        // Link'i çek - farklı formatları dene
        var linkMatch = RegExp(r'<link><!\[CDATA\[(.*?)\]\]></link>', dotAll: true)
            .firstMatch(itemContent);
        linkMatch ??= RegExp(r'<link>(.*?)</link>', dotAll: true)
            .firstMatch(itemContent);
        // Bazı feed'lerde guid içinde link olabilir (isPermaLink="true" veya isPermaLink='true' olanlar)
        linkMatch ??= RegExp(r'<guid[^>]*isPermaLink="true"[^>]*>(.*?)</guid>', dotAll: true)
            .firstMatch(itemContent);
        linkMatch ??= RegExp(r"<guid[^>]*isPermaLink='true'[^>]*>(.*?)</guid>", dotAll: true)
            .firstMatch(itemContent);
        // Guid içinde link olabilir (herhangi bir guid)
        linkMatch ??= RegExp(r'<guid[^>]*>(.*?)</guid>', dotAll: true)
            .firstMatch(itemContent);
        // Bazı feed'lerde link attribute olarak gelebilir
        linkMatch ??= RegExp(r'<item[^>]*link="(.*?)"', dotAll: true)
            .firstMatch(itemContent);
        linkMatch ??= RegExp(r"<item[^>]*link='(.*?)'", dotAll: true)
            .firstMatch(itemContent);
        
        final sourceMatch = RegExp(r'<source>(.*?)</source>').firstMatch(itemContent) ??
            RegExp(r'<dc:creator>(.*?)</dc:creator>').firstMatch(itemContent);
        
        if (titleMatch != null) {
          final title = _cleanHtmlTags(titleMatch.group(1) ?? '');
          final description = descriptionMatch != null
              ? _cleanHtmlTags(descriptionMatch.group(1) ?? '')
              : null;
          final source = sourceMatch != null
              ? _cleanHtmlTags(sourceMatch.group(1) ?? '')
              : 'Sağlık Haberleri';
          String? link;
          if (linkMatch != null) {
            link = linkMatch.group(1) ?? '';
            // HTML tag'lerini temizle ama URL'yi olduğu gibi bırak
            link = link.trim();
            // Eğer link HTML entity içeriyorsa decode et
            link = _decodeHtmlEntities(link);
          }

          if (title.isNotEmpty) {
            // Link kontrolü ve temizleme
            String? finalLink;
            if (link != null && link.isNotEmpty) {
              finalLink = link.trim();
              // Boş string kontrolü
              if (finalLink.isEmpty) {
                finalLink = null;
              } else {
                // URL formatını kontrol et
                if (!finalLink.startsWith('http://') && !finalLink.startsWith('https://')) {
                  // Eğer relative URL ise, feed URL'sinden base URL'i çıkar
                  // Şimdilik null bırak, çünkü base URL bilinmiyor
                  print('Uyarı: Relative URL bulundu: $finalLink');
                  finalLink = null;
                }
              }
            }
            
            articles.add(NewsArticle(
              title: title,
              source: source,
              description: description,
              url: finalLink,
            ));
            print('Haber eklendi: $title');
            print('  - Kaynak: $source');
            print('  - URL: ${finalLink ?? "YOK"}');
            if (finalLink == null) {
              print('  - UYARI: Bu haber için URL bulunamadı!');
            }
          }
        }
      }
    } catch (e) {
      print('RSS parse hatası: $e');
    }

    return articles;
  }

  /// HTML tag'lerini temizler ve HTML entity'lerini decode eder
  static String _cleanHtmlTags(String html) {
    // Önce HTML tag'lerini temizle
    String cleaned = html.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // HTML entity'lerini decode et
    cleaned = _decodeHtmlEntities(cleaned);
    
    // Boşlukları düzenle
    cleaned = cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    return cleaned;
  }

  /// HTML entity'lerini decode eder
  static String _decodeHtmlEntities(String text) {
    // Yaygın HTML entity'leri
    String decoded = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '…')
        .replaceAll('&lsquo;', ''')
        .replaceAll('&rsquo;', ''')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&euro;', '€')
        .replaceAll('&pound;', '£')
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;', '®');

    // Numeric HTML entity'leri decode et (&#8217; gibi)
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (match) {
        final code = int.tryParse(match.group(1) ?? '');
        if (code != null && code > 0 && code < 0x10FFFF) {
          return String.fromCharCode(code);
        }
        return match.group(0) ?? '';
      },
    );

    // Hexadecimal HTML entity'leri decode et (&#x2019; gibi)
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'),
      (match) {
        final code = int.tryParse(match.group(1) ?? '', radix: 16);
        if (code != null && code > 0 && code < 0x10FFFF) {
          return String.fromCharCode(code);
        }
        return match.group(0) ?? '';
      },
    );

    return decoded;
  }

  /// API çalışmazsa gösterilecek varsayılan haberler
  static List<NewsArticle> _getFallbackNews() {
    return [
      NewsArticle(
        title: 'DSÖ: Fiziksel aktivite rehberi güncellendi',
        source: 'Güncel Sağlık',
        description: 'Dünya Sağlık Örgütü fiziksel aktivite rehberini güncelledi.',
        url: 'https://www.who.int/news-room/fact-sheets/detail/physical-activity',
      ),
      NewsArticle(
        title: 'Akıllı saatlerle uyku takibi: Nelere dikkat etmeli?',
        source: 'Tekno Sağlık',
        description: 'Akıllı saatlerle uyku takibinde dikkat edilmesi gerekenler.',
        url: 'https://www.ntv.com.tr/saglik',
      ),
      NewsArticle(
        title: 'Omega-3 ve kalp sağlığı üzerine yeni meta-analiz',
        source: 'Tıp Dünyası',
        description: 'Omega-3 takviyelerinin kalp sağlığı üzerindeki etkileri araştırıldı.',
        url: 'https://www.haberturk.com/rss/kategori/saglik.xml',
      ),
    ];
  }

  /// Tahmini okuma süresini hesaplar (kelime sayısına göre)
  static int estimateReadingTime(String? text) {
    if (text == null || text.isEmpty) return 3;
    
    // Ortalama okuma hızı: dakikada 200 kelime
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    
    return minutes > 0 ? minutes : 3;
  }
}
