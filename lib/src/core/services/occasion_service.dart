import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Occasion {
  final String id;
  final String title;
  final String message;
  final int month;
  final int day;

  const Occasion({
    required this.id,
    required this.title,
    required this.message,
    required this.month,
    required this.day,
  });
}

class OccasionService {
  static const List<Occasion> occasions = [
    Occasion(
      id: 'ramadan',
      title: 'رمضان مبارك',
      message: 'مبارك عليكم الشهر، نسأل الله أن يعينكم فيه على الصيام والقيام وصالح الأعمال.',
      month: 9, 
      day: 1,
    ),
    Occasion(
      id: 'eid_fitr',
      title: 'عيد فطر سعيد',
      message: 'تقبل الله منا ومنكم صالح الأعمال، عيدكم مبارك وكل عام وأنتم بخير.',
      month: 10, 
      day: 1,
    ),
    Occasion(
      id: 'eid_adha',
      title: 'عيد أضحى مبارك',
      message: 'حج مبرور وسعي مشكور لمن حج، وكل عام والأمة الإسلامية بخير وعافية.',
      month: 12, 
      day: 10,
    ),
    Occasion(
      id: 'new_year',
      title: 'عام هجري جديد',
      message: 'نسأل الله أن يجعله عام خير وبركة ونصر للأمة الإسلامية.',
      month: 1, 
      day: 1,
    ),
    Occasion(
      id: 'mawlid',
      title: 'المولد النبوي الشريف',
      message: 'صلى عليك الله يا علم الهدى، كل عام وأنتم بخير بمناسبة مولد الهادي البشير.',
      month: 3, 
      day: 12,
    ),
    Occasion(
      id: 'isra_miraj',
      title: 'ذكرى الإسراء والمعراج',
      message: 'سُبْحَانَ الَّذِي أَسْرَىٰ بِعَبْدِهِ لَيْلًا مِّنَ الْمَسْجِدِ الْحَرَامِ إِلَى الْمَسْجِدِ الْأَقْصَى. مبارك عليكم ذكرى الإسراء والمعراج الشريفين.',
      month: 7, 
      day: 27,
    ),
    Occasion(
      id: 'mid_shaban',
      title: 'ليلة النصف من شعبان',
      message: 'ذكرى تحويل القبلة المباركة وغفران الذنوب. نسأل الله أن يبارك لنا في شعبان ويبلغنا رمضان وهو راضٍ عنا.',
      month: 8, 
      day: 15,
    ),
  ];

  static Future<Occasion?> checkOccasion() async {
    final today = HijriCalendar.now();
    
    // Find matching occasion for today
    try {
      final occasion = occasions.firstWhere(
        (o) => o.month == today.hMonth && o.day == today.hDay,
      );

      // Check if already shown this year
      final prefs = await SharedPreferences.getInstance();
      final key = 'occasion_${occasion.id}_${today.hYear}';
      
      if (prefs.getBool(key) == true) {
        return null; // Already shown
      }

      return occasion;
    } catch (_) {
      return null; // No occasion today
    }
  }

  static Future<void> markAsShown(Occasion occasion) async {
    final today = HijriCalendar.now();
    final prefs = await SharedPreferences.getInstance();
    final key = 'occasion_${occasion.id}_${today.hYear}';
    await prefs.setBool(key, true);
  }
}
