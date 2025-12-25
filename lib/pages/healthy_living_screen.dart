import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HealthyLivingScreen extends StatelessWidget {
  const HealthyLivingScreen({super.key});

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

    final List<_News> news = [
      _News(
        title: localizations?.whoPhysicalActivityUpdate ?? 'WHO: Physical activity guidelines updated',
        source: localizations?.currentHealthSource ?? 'Current Health',
        minutes: 3,
      ),
      _News(
        title: localizations?.smartWatchSleep ?? 'Sleep tracking with smartwatches: What to pay attention to?',
        source: localizations?.techHealthSource ?? 'Tech Health',
        minutes: 4,
      ),
      _News(
        title: localizations?.omega3HeartHealth ?? 'New meta-analysis on Omega-3 and heart health',
        source: localizations?.medicalWorldSource ?? 'Medical World',
        minutes: 5,
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
            Text(localizations?.currentNews ?? 'Current News', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...news.map((n) => _NewsTile(news: n, localizations: localizations!)).toList(),
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
  _News({required this.title, required this.source, required this.minutes});
}
