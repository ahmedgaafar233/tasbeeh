import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../../core/ui/universal_hijri_header.dart';
import '../../core/storage/local_store.dart';
import 'quran_models.dart';

class QuranPageView extends StatefulWidget {
  final List<QuranSurah> surahs;
  final int initialPage;

  const QuranPageView({
    super.key,
    required this.surahs,
    this.initialPage = 1,
  });

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  late final PageController _pageController;
  final List<TapGestureRecognizer> _recognizers = [];
  int _currentPage = 1;
  double _fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _saveLast(int surahId, int ayahId, int pageNum) {
    LocalStore.appBox.put('quran_last_surah', surahId);
    LocalStore.appBox.put('quran_last_ayah', ayahId);
    LocalStore.appBox.put('quran_last_page', pageNum);
    setState(() {});
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الموضع: صفحة $pageNum'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE1),
      appBar: AppBar(
        title: const Text('المصحف الشريف', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
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
      body: Column(
        children: [
          const UniversalHijriHeader(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 604,
              reverse: false, 
              onPageChanged: (idx) {
                setState(() => _currentPage = idx + 1);
              },
              itemBuilder: (context, index) {
                final pageNum = index + 1;
                return _buildMushafPage(pageNum);
              },
            ),
          ),
        ],
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

  Widget _buildMushafPage(int pageNum) {
    const beigeColor = Color(0xFFF5EFE1);
    const verseMarkerColor = Color(0xFF8B4513);
    const highlightColor = Color(0xFFFFF9C4);

    final lastSurahId = LocalStore.appBox.get('quran_last_surah');
    final lastAyahId = LocalStore.appBox.get('quran_last_ayah');

    final pageData = quran.getPageData(pageNum);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: Container(
          decoration: BoxDecoration(
            color: beigeColor,
            border: Border.all(color: Colors.brown[300]!, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(pageNum),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: pageData.map((data) {
                      final surahId = data['surah'] as int;
                      final startAyah = data['start'] as int;
                      final endAyah = data['end'] as int;
                      final surah = widget.surahs.firstWhere((s) => s.id == surahId);
                      
                      final versesCount = endAyah - startAyah + 1;
                      final versesInPage = surah.verses.skip(startAyah - 1).take(versesCount).toList();

                      return Column(
                        children: [
                          if (startAyah == 1 && surahId != 1 && surahId != 9)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
                                final r = TapGestureRecognizer()
                                  ..onTap = () => _saveLast(surahId, v.id, pageNum);
                                _recognizers.add(r);

                                final isHighlighted = lastSurahId == surahId && lastAyahId == v.id;
                                final isSajdah = quran.isSajdahVerse(surahId, v.id);

                                return TextSpan(
                                  children: [
                                    TextSpan(
                                      text: v.text,
                                      recognizer: r,
                                      style: TextStyle(
                                        fontSize: _fontSize,
                                        height: 1.6, // Reduced from 2.1 for better fit
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
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              _buildFooter(pageNum),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int pageNum) {
    final firstEntry = quran.getPageData(pageNum).first;
    final surahId = firstEntry['surah'];
    final ayahId = firstEntry['start'];
    final juzNum = quran.getJuzNumber(surahId, ayahId);
    final surahName = quran.getSurahNameArabic(surahId);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.brown[200]!)),
        color: Colors.brown[100]!.withOpacity(0.2), // Darkened for better contrast
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('الجزء $juzNum', 
               style: TextStyle(fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown[800])),
          Text(surahName, 
               style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown[900])),
        ],
      ),
    );
  }

  Widget _buildFooter(int pageNum) {
    return Container(
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
    );
  }

  String _toArabicDigits(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
