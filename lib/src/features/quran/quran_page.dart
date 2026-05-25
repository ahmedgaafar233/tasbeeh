import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../../core/storage/local_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/glass.dart';
import '../../core/ui/universal_hijri_header.dart';
import '../../core/ui/glass_scaffold.dart';
import 'quran_page_view.dart';
import 'quran_models.dart';
import 'quran_repository.dart';
import 'quran_search_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late final Future<List<QuranSurah>> surahsFuture =
      QuranRepository.instance.load();

  @override
  Widget build(BuildContext context) {
    final lastSurah = LocalStore.appBox.get('quran_last_surah');
    final lastAyah = LocalStore.appBox.get('quran_last_ayah');

    return GlassScaffold(
      title: 'القرآن الكريم',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'بحث',
          onPressed: () async {
            final surahs = await surahsFuture;
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => QuranSearchPage(surahs: surahs)),
            );
          },
        ),
      ],
      body: FutureBuilder<List<QuranSurah>>(
        future: surahsFuture,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('خطأ: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<QuranSurah> surahs = snap.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              const UniversalHijriHeader(),
              const SizedBox(height: 10),

              // ✅ متابعة القراءة
              GlassCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(Icons.bookmark, color: AppTheme.goldMain),
                  title: const Text('متابعة القراءة', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: (lastSurah is int && lastAyah is int)
                              ? 'السورة: ${quran.getSurahNameArabic(lastSurah)} • آية: $lastAyah'
                              : 'ابدأ القراءة الآن',
                        ),
                        if (lastSurah is int && lastAyah is int && quran.isSajdahVerse(lastSurah, lastAyah))
                          const TextSpan(
                            text: ' (سجدة)',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () async {
                    final pageNum = LocalStore.appBox.get('quran_last_page') ?? 1;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuranPageView(surahs: surahs, initialPage: pageNum),
                      ),
                    );
                    if (context.mounted) setState(() {});
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Text('سور القرآن الكريم', 
                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Amiri')),
              const SizedBox(height: 10),

              // ✅ قائمة السور
              ...surahs.map((s) {
                final isMeccan = quran.getPlaceOfRevelation(s.id) == 'Makkah';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: ShinyGoldBorder(
                        radius: 12,
                        width: 1.5,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.black54 
                              : Colors.white70,
                          child: Text(
                            _toArabicDigits(s.id),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      title: Text(s.name, style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('آياتها: ${_toArabicDigits(s.totalVerses)} • ${isMeccan ? 'مكية' : 'مدنية'}'),
                      trailing: Icon(
                        isMeccan ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                        size: 18,
                        color: AppTheme.goldMain,
                      ),
                      onTap: () async {
                        final pageNum = quran.getPageNumber(s.id, 1);
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => QuranPageView(surahs: surahs, initialPage: pageNum)),
                        );
                        if (context.mounted) setState(() {});
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _toArabicDigits(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}