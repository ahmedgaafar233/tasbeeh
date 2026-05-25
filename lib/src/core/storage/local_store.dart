import 'package:hive/hive.dart';

class LocalStore {
  static bool isInitialized = false;
  static late Box appBox;
  static late Box savedTasbeehBox;
  static late Box customDhikrBox;
  static late Box dhikrCountersBox;
  static late Box prayerBox;
  static late Box hijriBox;

  static Future<void> init() async {
    appBox = await Hive.openBox('app');
    savedTasbeehBox = await Hive.openBox('saved_tasbeeh');
    customDhikrBox = await Hive.openBox('custom_dhikr');
    dhikrCountersBox = await Hive.openBox('dhikr_counters');
    prayerBox = await Hive.openBox('prayer');
    hijriBox = await Hive.openBox('hijri');
    isInitialized = true;
  }
}