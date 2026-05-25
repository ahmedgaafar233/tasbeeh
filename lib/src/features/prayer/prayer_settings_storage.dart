import '../../core/storage/local_store.dart';

class PrayerSettingsStorage {
  static const _kEnabled = 'adhanEnabled';
  static const _kSoundEnabled = 'adhanSoundEnabled';
  static const _kPerPrayer = 'prayerEnabled'; // Map<String,bool>

  static const _kLat = 'lat';
  static const _kLon = 'lon';
  static const _kMethod = 'method';
  static const _kScheduleUntil = 'scheduleUntil';

  // keys
  static const fajr = 'fajr';
  static const dhuhr = 'dhuhr';
  static const asr = 'asr';
  static const maghrib = 'maghrib';
  static const isha = 'isha';

  static const allKeys = [fajr, dhuhr, asr, maghrib, isha];

  static bool get enabled =>
      (LocalStore.prayerBox.get(_kEnabled) ?? false) as bool;

  static Future<void> setEnabled(bool v) =>
      LocalStore.prayerBox.put(_kEnabled, v);

  /// true = بصوت، false = صامت
  static bool get soundEnabled =>
      (LocalStore.prayerBox.get(_kSoundEnabled) ?? true) as bool;

  static Future<void> setSoundEnabled(bool v) =>
      LocalStore.prayerBox.put(_kSoundEnabled, v);

  static Map<String, bool> get perPrayerEnabled {
    final raw = LocalStore.prayerBox.get(_kPerPrayer);
    final Map<String, bool> def = {
      fajr: true,
      dhuhr: true,
      asr: true,
      maghrib: true,
      isha: true,
    };

    if (raw is Map) {
      final map = <String, bool>{};
      for (final k in def.keys) {
        map[k] = (raw[k] ?? def[k]) == true;
      }
      return map;
    }
    return def;
  }

  static bool isPrayerEnabled(String key) {
    return perPrayerEnabled[key] ?? true;
  }

  static Future<void> setPrayerEnabled(String key, bool value) async {
    final map = perPrayerEnabled;
    map[key] = value;
    await LocalStore.prayerBox.put(_kPerPrayer, map);
  }

  static Future<void> setAll(bool value) async {
    final map = {for (final k in allKeys) k: value};
    await LocalStore.prayerBox.put(_kPerPrayer, map);
  }

  static Future<void> setLocation({required double lat, required double lon}) async {
    await LocalStore.prayerBox.put(_kLat, lat);
    await LocalStore.prayerBox.put(_kLon, lon);
  }

  static (double, double)? getLocation() {
    final lat = LocalStore.prayerBox.get(_kLat);
    final lon = LocalStore.prayerBox.get(_kLon);
    if (lat is num && lon is num) return (lat.toDouble(), lon.toDouble());
    return null;
  }

  static String get methodKey =>
      (LocalStore.prayerBox.get(_kMethod) ?? 'mwl').toString();

  static Future<void> setMethodKey(String v) =>
      LocalStore.prayerBox.put(_kMethod, v);

  static DateTime? get scheduleUntil {
    final iso = LocalStore.prayerBox.get(_kScheduleUntil);
    return iso is String ? DateTime.tryParse(iso) : null;
  }

  static Future<void> setScheduleUntil(DateTime dt) =>
      LocalStore.prayerBox.put(_kScheduleUntil, dt.toIso8601String());

  static const _kLocationName = 'locationName';
  static const _kLastRescheduled = 'lastRescheduled';

  static String? get locationName =>
      LocalStore.prayerBox.get(_kLocationName) as String?;

  static Future<void> setLocationName(String? name) =>
      LocalStore.prayerBox.put(_kLocationName, name);

  static DateTime? get lastRescheduled {
    final iso = LocalStore.prayerBox.get(_kLastRescheduled);
    return iso is String ? DateTime.tryParse(iso) : null;
  }

  static Future<void> setLastRescheduled(DateTime dt) =>
      LocalStore.prayerBox.put(_kLastRescheduled, dt.toIso8601String());
}