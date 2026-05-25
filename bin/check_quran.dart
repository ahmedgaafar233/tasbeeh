import 'package:quran/quran.dart' as quran;

void main() {
  print('Testing quran package methods:');
  try {
    print('isSajdahVerse(1, 1): ${quran.isSajdahVerse(1, 1)}');
  } catch (e) {
    print('isSajdahVerse failed: $e');
  }
}
