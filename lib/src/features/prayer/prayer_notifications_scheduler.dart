import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';

import '../../core/notifications/notification_service.dart';
import 'prayer_settings_storage.dart';

class PrayerNotificationsScheduler {
  static CalculationParameters _paramsFromKey(String key) {
    switch (key) {
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'karachi':
        return CalculationMethod.karachi.getParameters();
      case 'dubai':
        return CalculationMethod.dubai.getParameters();
      case 'mwl':
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  static Future<void> rescheduleFromSavedSettings({int days = 14}) async {
    final enabled = PrayerSettingsStorage.enabled;
    if (!enabled) {
      await NotificationService.cancelAll();
      return;
    }

    final loc = PrayerSettingsStorage.getLocation();
    if (loc == null) return;

    final (lat, lon) = loc;
    final methodKey = PrayerSettingsStorage.methodKey;
    final soundEnabled = PrayerSettingsStorage.soundEnabled;
    final per = PrayerSettingsStorage.perPrayerEnabled;

    // Cancel old schedules before scheduling new ones
    await NotificationService.cancelAll();

    final coordinates = Coordinates(lat, lon);
    final params = _paramsFromKey(methodKey)..madhab = Madhab.shafi;

    final now = DateTime.now();

    for (int dayOffset = 0; dayOffset < days; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final dc = DateComponents.from(date);
      final t = PrayerTimes(coordinates, dc, params);

      // Unique IDs per day offset
      final base = 10000 + (dayOffset * 10);

      if (per[PrayerSettingsStorage.fajr] == true) {
        await NotificationService.scheduleAdhan(
          id: base + 1,
          title: 'أذان الفجر',
          body: 'حان الآن وقت صلاة الفجر',
          dateTime: t.fajr,
          soundEnabled: soundEnabled,
          prayerName: 'الفجر',
        );
      }
      if (per[PrayerSettingsStorage.dhuhr] == true) {
        await NotificationService.scheduleAdhan(
          id: base + 2,
          title: 'أذان الظهر',
          body: 'حان الآن وقت صلاة الظهر',
          dateTime: t.dhuhr,
          soundEnabled: soundEnabled,
          prayerName: 'الظهر',
        );
      }
      if (per[PrayerSettingsStorage.asr] == true) {
        await NotificationService.scheduleAdhan(
          id: base + 3,
          title: 'أذان العصر',
          body: 'حان الآن وقت صلاة العصر',
          dateTime: t.asr,
          soundEnabled: soundEnabled,
          prayerName: 'العصر',
        );
      }
      if (per[PrayerSettingsStorage.maghrib] == true) {
        await NotificationService.scheduleAdhan(
          id: base + 4,
          title: 'أذان المغرب',
          body: 'حان الآن وقت صلاة المغرب',
          dateTime: t.maghrib,
          soundEnabled: soundEnabled,
          prayerName: 'المغرب',
        );
      }
      if (per[PrayerSettingsStorage.isha] == true) {
        await NotificationService.scheduleAdhan(
          id: base + 5,
          title: 'أذان العشاء',
          body: 'حان الآن وقت صلاة العشاء',
          dateTime: t.isha,
          soundEnabled: soundEnabled,
          prayerName: 'العشاء',
        );
      }
      
      // Sunrise Notification (light/soft reminder - plays default notification sound, no full adhan)
      await NotificationService.scheduleAdhan(
        id: base + 6,
        title: 'شروق الشمس',
        body: 'حان الآن موعد شروق الشمس',
        dateTime: t.sunrise,
        soundEnabled: true, // Plays default system notification sound (short beep)
        prayerName: 'الشروق',
      );
    }

    await PrayerSettingsStorage.setScheduleUntil(
      DateTime.now().add(Duration(days: days)),
    );
    await PrayerSettingsStorage.setLastRescheduled(DateTime.now());
  }

  /// Run when the app starts: silently reschedule if scheduledUntil is close to expiring, or 24 hours have passed.
  static Future<void> tryAutoReschedule() async {
    if (!PrayerSettingsStorage.enabled) return;

    final lastResched = PrayerSettingsStorage.lastRescheduled;
    final now = DateTime.now();

    final shouldReschedule = lastResched == null ||
        now.difference(lastResched).inHours >= 24 ||
        PrayerSettingsStorage.scheduleUntil == null ||
        PrayerSettingsStorage.scheduleUntil!.isBefore(now.add(const Duration(days: 3)));

    if (shouldReschedule) {
      final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
      final scheduleDays = isIOS ? 12 : 30;
      await rescheduleFromSavedSettings(days: scheduleDays);
    }
  }
}