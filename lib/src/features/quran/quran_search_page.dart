import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'quran_models.dart';
import 'quran_page_view.dart';

class QuranSearchPage extends StatefulWidget {
  final List<QuranSurah> surahs;
  const QuranSearchPage({super.key, required this.surahs});

  @override
  State<QuranSearchPage> createState() => _QuranSearchPageState();
}

class _QuranSearchPageState extends State<QuranSearchPage> {
  final c = TextEditingController();
  List<_Result> results = [];

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void search(String q) {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }

    final list = <_Result>[];

    // Check if query is a number (Page or Juz)
    final numValue = int.tryParse(query);
    if (numValue != null) {
      if (numValue >= 1 && numValue <= 604) {
        // Find starting surah for this page
        final surahId = quran.getPageData(numValue)[0]['surah'];
        final startAyahId = quran.getPageData(numValue)[0]['start'];
        final surah = widget.surahs.firstWhere((s) => s.id == surahId);
        list.add(_Result(
          surah: surah, 
          ayah: surah.verses.firstWhere((v) => v.id == startAyahId),
          type: 'انتقال إلى صفحة $numValue',
        ));
      }
      if (numValue >= 1 && numValue <= 30) {
        // Find starting surah for this Juz
        final juzStart = quran.getSurahAndVersesFromJuz(numValue);
        final surahId = juzStart.keys.first;
        final startAyahId = juzStart[surahId]![0];
        final surah = widget.surahs.firstWhere((s) => s.id == surahId);
        list.add(_Result(
          surah: surah, 
          ayah: surah.verses.firstWhere((v) => v.id == startAyahId),
          type: 'انتقال إلى الجزء $numValue',
        ));
      }
    }

    // Text search
    if (query.length > 2) {
      for (final s in widget.surahs) {
        for (final v in s.verses) {
          if (v.text.contains(query)) {
            list.add(_Result(surah: s, ayah: v));
          }
        }
      }
    }

    setState(() => results = list.take(200).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بحث في القرآن')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: c,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ابحث عن كلمة أو رقم صفحة/جزء',
                hintText: 'مثلاً: 50 للذهاب لصفحة 50',
              ),
              onChanged: search,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('ابدأ بالبحث…'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final r = results[i];
                        final isNavigation = r.type != null;

                        return Card(
                          color: isNavigation ? Colors.amber[50] : null,
                          child: ListTile(
                            leading: Icon(
                              isNavigation ? Icons.map : Icons.description,
                              color: isNavigation ? Colors.amber[900] : null,
                            ),
                            title: Text(
                              r.type ?? '${r.surah.name} - آية ${r.ayah.id}',
                              style: TextStyle(
                                fontWeight: isNavigation ? FontWeight.bold : null,
                              ),
                            ),
                            subtitle: Text(
                              isNavigation 
                                  ? 'تبدأ بـ: ${r.surah.name}' 
                                  : r.ayah.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Amiri'),
                            ),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: () {
                              final pageNum = quran.getPageNumber(r.surah.id, r.ayah.id);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => QuranPageView(
                                    surahs: widget.surahs,
                                    initialPage: pageNum,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Result {
  final QuranSurah surah;
  final QuranAyah ayah;
  final String? type;
  const _Result({required this.surah, required this.ayah, this.type});
}