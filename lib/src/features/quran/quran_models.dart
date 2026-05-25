class QuranSurah {
  final int id;
  final String name;
  final int totalVerses;
  final List<QuranAyah> verses;

  const QuranSurah({
    required this.id,
    required this.name,
    required this.totalVerses,
    required this.verses,
  });
}

class QuranAyah {
  final int id; // رقم الآية داخل السورة (1..)
  final String text;

  const QuranAyah({required this.id, required this.text});
}