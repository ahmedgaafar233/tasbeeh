import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:tasbeeh_app/src/core/notifications/notification_service.dart';
import 'package:tasbeeh_app/src/core/notifications/prayer_time_alert.dart';
import 'package:tasbeeh_app/src/features/prayer/prayer_settings_storage.dart';

class PrayerForegroundMonitor {
  static Timer? _timer;
  static bool _isDialogShowing = false;

  static void start(BuildContext context) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkPrayerTime(context);
    });
    // check once immediately on start
    _checkPrayerTime(context);
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static void _checkPrayerTime(BuildContext context) {
    if (!PrayerSettingsStorage.enabled || _isDialogShowing) return;

    final loc = PrayerSettingsStorage.getLocation();
    if (loc == null) return;

    final (lat, lon) = loc;
    final methodKey = PrayerSettingsStorage.methodKey;
    final coordinates = Coordinates(lat, lon);
    
    // Simple method mapping (copied from scheduler for consistency)
    CalculationParameters params;
    switch (methodKey) {
      case 'umm_al_qura': params = CalculationMethod.umm_al_qura.getParameters(); break;
      case 'egyptian': params = CalculationMethod.egyptian.getParameters(); break;
      case 'karachi': params = CalculationMethod.karachi.getParameters(); break;
      case 'dubai': params = CalculationMethod.dubai.getParameters(); break;
      default: params = CalculationMethod.muslim_world_league.getParameters(); break;
    }
    params.madhab = Madhab.shafi;

    final now = DateTime.now();
    final dc = DateComponents.from(now);
    final t = PrayerTimes(coordinates, dc, params);

    // Check if current minute matches any prayer time
    _check(context, 'الفجر', t.fajr, now);
    _check(context, 'الظهر', t.dhuhr, now);
    _check(context, 'العصر', t.asr, now);
    _check(context, 'المغرب', t.maghrib, now);
    _check(context, 'العشاء', t.isha, now);
  }

  static void _check(BuildContext context, String name, DateTime prayerTime, DateTime now) {
    if (NotificationService.adhanPlayingNotifier.value != null) return;
    
    // If current time is within 1 minute of prayer time
    final diff = now.difference(prayerTime).inMinutes.abs();
    if (diff == 0) {
      if (PrayerSettingsStorage.soundEnabled) {
        NotificationService.playFullAthan(name);
      } else {
        NotificationService.adhanPlayingNotifier.value = name;
      }
    }
  }
}
