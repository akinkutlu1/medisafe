import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../l10n/app_localizations.dart';
import '../services/news_service.dart';

class HealthyLivingScreen extends StatefulWidget {
  const HealthyLivingScreen({super.key});

  @override
  State<HealthyLivingScreen> createState() => _HealthyLivingScreenState();
}

class _HealthyLivingScreenState extends State<HealthyLivingScreen> {
  List<NewsArticle> _news = [];
  bool _isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoadingNews = true);
    
    try {
      final news = await NewsService.getHealthNews(limit: 3);
      setState(() {
        _news = news;
        _isLoadingNews = false;
      });
    } catch (e) {
      setState(() => _isLoadingNews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1E66A6);
    final localizations = AppLocalizations.of(context);

    final List<_Tip> tips = [
      _Tip(
        title: localizations?.increaseWaterIntake ?? 'Increase water intake',
        description: localizations?.waterIntakeDescription ?? 'Drinking 6-8 glasses of water a day improves mental and physical performance.',
      ),
      _Tip(
        title: localizations?.thirtyMinutesExercise ?? '30 minutes of movement',
        description: localizations?.exerciseDescription ?? 'Light-paced daily walking supports heart health.',
      ),
      _Tip(
        title: localizations?.regularSleep ?? 'Regular sleep',
        description: localizations?.sleepDescription ?? '7-8 hours of sleep strengthens the immune system.',
      ),
      _Tip(
        title: localizations?.vegetablesAndFruits ?? 'Vegetables & fruits',
        description: localizations?.vegetablesDescription ?? 'Colorful plates provide more vitamins and fiber.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.healthyLivingTitle ?? 'Healthy Living'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Header(primaryBlue: primaryBlue, localizations: localizations!),
            const SizedBox(height: 16),
            Text(localizations?.dailyTips ?? 'Daily Tips', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...tips.map((t) => _TipCard(tip: t)).toList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations?.currentNews ?? 'Current News', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                if (_isLoadingNews)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadNews,
                    tooltip: 'Yenile',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoadingNews)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_news.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Haber bulunamadı',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ..._news.map((article) {
                return _NewsTile(
                  news: _News(
                    title: article.title,
                    source: article.source,
                    minutes: NewsService.estimateReadingTime(article.description ?? article.title),
                    url: article.url,
                  ),
                  localizations: localizations!,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.primaryBlue, required this.localizations});
  final Color primaryBlue;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [primaryBlue, primaryBlue.withOpacity(0.7)]),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations!.healthyLivingMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});
  final _Tip tip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(tip.description),
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.news, required this.localizations});
  final _News news;
  final AppLocalizations localizations;

  Future<void> _launchUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bu haber için link bulunamadı. Haber kaynağından link alınamadı.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // URL'yi temizle ve düzelt
    String cleanUrl = url.trim();
    
    // Eğer URL http/https ile başlamıyorsa ekle
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    try {
      print('Açılacak URL: $cleanUrl');
      
      // Platform channel hatasını önlemek için direkt launchUrlString kullan
      // Bu metod daha stabil ve platform channel sorunlarını önler
      final uri = Uri.parse(cleanUrl);
      final launched = await launcher.launchUrl(
        uri,
        mode: launcher.LaunchMode.externalApplication,
      );
      
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link açılamadı. Lütfen tekrar deneyin.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('URL açma hatası: $e');
      
      // Platform channel hatası varsa kullanıcıya URL'yi kopyala seçeneği sun
      if (e.toString().contains('channel-error') || e.toString().contains('PlatformException')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Link Açılamadı'),
            content: Text('Link tarayıcıda açılamadı.\n\nURL: $cleanUrl'),
            actions: [
              TextButton(
                onPressed: () {
                  // URL'yi panoya kopyala
                  Clipboard.setData(ClipboardData(text: cleanUrl));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL panoya kopyalandı. Tarayıcınıza yapıştırabilirsiniz.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text('URL\'yi Kopyala'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Tekrar dene
                  await Future.delayed(const Duration(milliseconds: 500));
                  _launchUrl(context, cleanUrl);
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link açılamadı. Lütfen internet bağlantınızı kontrol edin.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.article_outlined, color: Colors.blue),
        title: Text(news.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(news.source, style: const TextStyle(fontSize: 12)),
            Text(localizations!.readingTime(news.minutes), style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _launchUrl(context, news.url),
      ),
    );
  }
}

class _Tip {
  final String title;
  final String description;
  _Tip({required this.title, required this.description});
}

class _News {
  final String title;
  final String source;
  final int minutes;
  final String? url;
  _News({
    required this.title,
    required this.source,
    required this.minutes,
    this.url,
  });
}
