import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../../core/storage/local_store.dart';
import 'quran_models.dart';

class SurahPage extends StatefulWidget {
  final QuranSurah surah;
  final int? jumpToAyah;

  const SurahPage({super.key, required this.surah, this.jumpToAyah});

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  final Map<int, GlobalKey> _ayahKeys = {};
  final List<TapGestureRecognizer> _recognizers = [];
  double _fontSize = 25.0;

  @override
  void initState() {
    super.initState();
    for (var v in widget.surah.verses) {
      _ayahKeys[v.id] = GlobalKey();
    }

    if (widget.jumpToAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToAyah(widget.jumpToAyah!));
    }
  }

  @override
  void dispose() {
    for (var r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _jumpToAyah(int ayahId) {
    final key = _ayahKeys[ayahId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveLast(int ayahId) {
    LocalStore.appBox.put('quran_last_surah', widget.surah.id);
    LocalStore.appBox.put('quran_last_ayah', ayahId);
    setState(() {}); // Refresh to show highlight
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الموضع: ${widget.surah.name} • آية $ayahId'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _showZoomDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('حجم الخط', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _fontSize,
                min: 18,
                max: 40,
                divisions: 11,
                activeColor: Colors.brown,
                onChanged: (v) {
                  setDialogState(() => _fontSize = v);
                  setState(() => _fontSize = v);
                },
              ),
              Text('${_fontSize.toInt()} px', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('تم')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    _recognizers.clear();

    final lastSurahId = LocalStore.appBox.get('quran_last_surah');
    final lastAyahId = LocalStore.appBox.get('quran_last_ayah');
    final isCurrentSurah = lastSurahId == s.id;

    const beigeColor = Color(0xFFF5EFE1);
    const verseMarkerColor = Color(0xFF8B4513);
    const highlightColor = Color(0xFFFFF9C4);

    final Map<int, List<QuranAyah>> pageGroups = {};
    for (var v in s.verses) {
      final pageNum = quran.getPageNumber(s.id, v.id);
      pageGroups.putIfAbsent(pageNum, () => []).add(v);
    }

    final sortedPageNumbers = pageGroups.keys.toList()..sort();

    return Scaffold(
      backgroundColor: beigeColor,
      appBar: AppBar(
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.brown[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _showZoomDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: sortedPageNumbers.map((pageNum) {
            final versesInPage = pageGroups[pageNum]!;
            final firstAyah = versesInPage.first;
            final juzNum = quran.getJuzNumber(s.id, firstAyah.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: beigeColor,
                    border: Border.all(color: Colors.brown[300]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.brown[200]!)),
                          color: Colors.brown[100]!.withOpacity(0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الجزء $juzNum', 
                                 style: TextStyle(fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown[800])),
                            Text(s.name, 
                                 style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown[900])),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          children: [
                            if (versesInPage.any((v) => v.id == 1) && s.id != 1 && s.id != 9)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                  style: TextStyle(
                                    fontSize: _fontSize + 2,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Amiri',
                                    color: Colors.brown[900],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            SelectableText.rich(
                              TextSpan(
                                children: versesInPage.map((v) {
                                  final r = TapGestureRecognizer()..onTap = () => _saveLast(v.id);
                                  _recognizers.add(r);

                                  final isHighlighted = isCurrentSurah && lastAyahId == v.id;
                                  final isSajdah = quran.isSajdahVerse(s.id, v.id);

                                  return TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: SizedBox(
                                          key: _ayahKeys[v.id],
                                          width: 0,
                                          height: 0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: v.text,
                                        recognizer: r,
                                        style: TextStyle(
                                          fontSize: _fontSize,
                                          height: 1.6,
                                          color: Colors.black,
                                          fontFamily: 'Amiri',
                                          backgroundColor: isHighlighted ? highlightColor : null,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ﴿${_toArabicDigits(v.id)}﴾${isSajdah ? ' ۩ ' : ' '}',
                                        style: TextStyle(
                                          fontSize: _fontSize * 0.8,
                                          color: verseMarkerColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Amiri',
                                          backgroundColor: isHighlighted ? highlightColor : null,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.brown[200]!)),
                          color: Colors.brown[100]!.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            _toArabicDigits(pageNum),
                            style: TextStyle(fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown[900]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _toArabicDigits(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}