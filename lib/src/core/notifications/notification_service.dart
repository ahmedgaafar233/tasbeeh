import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static bool _initialized = false;

  static const String _soundChannelId = 'adhan_channel_sound_v1';
  static const String _fajrChannelId = 'adhan_channel_fajr_v1';
  static const String _silentChannelId = 'adhan_channel_silent_v1';

  static const String _channelName = 'تنبيهات الأذان';
  static const String _channelDesc = 'تنبيهات مواقيت الصلاة';

  // Global notifiers for the FullScreenAdhanAlert overlay
  static final ValueNotifier<String?> adhanPlayingNotifier = ValueNotifier<String?>(null);
  static final ValueNotifier<double> adhanVolumeNotifier = ValueNotifier<double>(1.0);
  static final ValueNotifier<Duration> adhanPositionNotifier = ValueNotifier<Duration>(Duration.zero);

  static String _extractTimezoneName(Object tzValue) {
    if (tzValue is String) return tzValue;

    // flutter_timezone 5.x might return TimezoneInfo (different field names across versions)
    try {
      final v = (tzValue as dynamic).name;
      if (v != null) return v.toString();
    } catch (_) {}

    try {
      final v = (tzValue as dynamic).timeZoneName;
      if (v != null) return v.toString();
    } catch (_) {}

    try {
      final v = (tzValue as dynamic).timezone;
      if (v != null) return v.toString();
    } catch (_) {}

    try {
      final v = (tzValue as dynamic).identifier;
      if (v != null) return v.toString();
    } catch (_) {}

    // fallback safe value
    return 'UTC';
  }

  static Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const settings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        // Play full Athan when notification is clicked
        if (response.id != 998) { // Don't loop test notification infinitely
          final prayerName = response.payload ?? 'الصلاة';
          await playFullAthan(prayerName);
        }
      },
    );

    // Stop alert state when sound finishes playing
    _audioPlayer.onPlayerComplete.listen((event) {
      adhanPlayingNotifier.value = null;
      adhanPositionNotifier.value = Duration.zero;
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      adhanPositionNotifier.value = pos;
    });

    // timezone
    tz.initializeTimeZones();
    final tzValue = await FlutterTimezone.getLocalTimezone();
    final tzName = _extractTimezoneName(tzValue);
    tz.setLocalLocation(tz.getLocation(tzName));

    // Check if the app was launched from a notification
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final response = launchDetails.notificationResponse;
      if (response != null && response.id != 998) {
        final prayerName = response.payload ?? 'الصلاة';
        Future.delayed(const Duration(milliseconds: 500), () {
          playFullAthan(prayerName);
        });
      }
    }

    await requestPermissions();
    await _createChannels();

    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.requestNotificationsPermission();

    try {
      await (android as dynamic).requestExactAlarmsPermission();
    } catch (_) {}
  }

  static Future<void> _createChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    const soundChannel = AndroidNotificationChannel(
      _soundChannelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
    );

    const fajrChannel = AndroidNotificationChannel(
      _fajrChannelId,
      'تنبيه أذان الفجر',
      description: 'تنبيه صلاة الفجر المخصوص بالصلاة خير من النوم',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
    );

    const silentChannel = AndroidNotificationChannel(
      _silentChannelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: false,
      enableVibration: true,
    );

    await android.createNotificationChannel(soundChannel);
    await android.createNotificationChannel(fajrChannel);
    await android.createNotificationChannel(silentChannel);
  }

  static NotificationDetails _details({required bool soundEnabled, String? prayerName}) {
    final isFajr = prayerName == 'الفجر';
    final channelId = soundEnabled 
        ? (isFajr ? _fajrChannelId : _soundChannelId)
        : _silentChannelId;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: soundEnabled,
        sound: null, // Default system notification sound to avoid overlapping double Adhan
        audioAttributesUsage: AudioAttributesUsage.notification,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      ),
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);

  static int _getTodayId(String prayerName) {
    switch (prayerName) {
      case 'الفجر': return 10001;
      case 'الظهر': return 10002;
      case 'العصر': return 10003;
      case 'المغرب': return 10004;
      case 'العشاء': return 10005;
      default: return 998;
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<void> setVolume(double vol) async {
    final clamped = vol.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(clamped);
    adhanVolumeNotifier.value = clamped;
  }

  static Future<void> stopAthan() async {
    await _audioPlayer.stop();
    adhanPlayingNotifier.value = null;
    adhanPositionNotifier.value = Duration.zero;
  }

  static Future<void> playFullAthan([String prayerName = 'الصلاة']) async {
    if (prayerName == 'الشروق') return; // Sunrise notification is soft/light, no full screen or Adhan sound
    try {
      final id = _getTodayId(prayerName);
      await _plugin.cancel(id);

      await _audioPlayer.stop();
      adhanPositionNotifier.value = Duration.zero;

      // Configure audio context to request wake lock, set media stream usage (volume buttons)
      // and bypass focus changes so other notification sounds don't interrupt us
      await _audioPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none, // Bypasses focus requests so nothing can interrupt or pause it
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      ));

      await _audioPlayer.setVolume(adhanVolumeNotifier.value);
      final isFajr = prayerName == 'الفجر';
      final assetPath = isFajr ? 'audio/adhan_fajr.mp3' : 'audio/adhan.mp3';
      await _audioPlayer.play(AssetSource(assetPath));
      adhanPlayingNotifier.value = prayerName;
    } catch (e) {
      debugPrint('Error playing full athan: $e');
    }
  }

  static Future<void> testNow({required bool soundEnabled}) async {
    // Show notification
    await _plugin.show(
      998,
      'حان الآن موعد الأذان (تجربة)',
      'الله أكبر، الله أكبر (اضغط للتجربة الكاملة)',
      _details(soundEnabled: soundEnabled, prayerName: 'تجربة'),
      payload: 'تجربة',
    );

    // Play a short preview immediately if sound enabled
    if (soundEnabled) {
      await playFullAthan('تجربة');
      await Future.delayed(const Duration(seconds: 10));
      await stopAthan();
    }
  }

  static Future<void> scheduleAdhan({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required bool soundEnabled,
    required String prayerName,
  }) async {
    final scheduled = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(soundEnabled: soundEnabled, prayerName: prayerName),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: prayerName,
    );
  }
}