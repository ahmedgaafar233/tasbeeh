import 'dart:convert';
import 'package:flutter/services.dart';

import 'quran_models.dart';

class QuranRepository {
  QuranRepository._();
  static final QuranRepository instance = QuranRepository._();

  List<QuranSurah>? _cache;

  Future<List<QuranSurah>> load() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/quran/quran.json');
    final decoded = jsonDecode(raw);

    // quran-json غالبًا List of surahs
    if (decoded is! List) {
      throw Exception('Unexpected Quran JSON format (expected List).');
    }

    final surahs = <QuranSurah>[];

    for (final s in decoded) {
      if (s is! Map) continue;

      final id = (s['id'] as num).toInt();
      final name = (s['name'] ?? '').toString();
      final totalVerses = (s['total_verses'] as num?)?.toInt() ??
          (s['totalVerses'] as num?)?.toInt() ??
          0;

      final versesRaw = s['verses'];
      final verses = <QuranAyah>[];

      if (versesRaw is List) {
        for (int i = 0; i < versesRaw.length; i++) {
          final v = versesRaw[i];

          // بعض النسخ: verse = {id, text}
          if (v is Map) {
            final vid = (v['id'] as num?)?.toInt() ?? (i + 1);
            final text = (v['text'] ?? '').toString();
            verses.add(QuranAyah(id: vid, text: text));
          }
          // لو كانت String مباشرة
          else if (v is String) {
            verses.add(QuranAyah(id: i + 1, text: v));
          }
        }
      }

      surahs.add(QuranSurah(
        id: id,
        name: name,
        totalVerses: totalVerses == 0 ? verses.length : totalVerses,
        verses: verses,
      ));
    }

    _cache = surahs;
    return surahs;
  }
}