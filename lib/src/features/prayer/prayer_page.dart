import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/storage/local_store.dart';
import 'prayer_notifications_scheduler.dart';
import 'prayer_settings_storage.dart';
import '../../core/ui/hijri_chip.dart';
import '../../core/ui/glass_scaffold.dart';



class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  Position? pos;
  String? error;
  PrayerTimes? times;
  String? locationName;

  String methodKey = (LocalStore.prayerBox.get('method') ?? 'mwl').toString();

  @override
  void initState() {
    super.initState();
    _load();
  }

  CalculationParameters _paramsFromKey(String key) {
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

  Future<void> _load() async {
    // 1. Load cached location first
    final cachedLoc = PrayerSettingsStorage.getLocation();
    final cachedName = PrayerSettingsStorage.locationName;
    
    if (cachedLoc != null) {
      final coordinates = Coordinates(cachedLoc.$1, cachedLoc.$2);
      final params = _paramsFromKey(methodKey)..madhab = Madhab.shafi;
      final date = DateComponents.from(DateTime.now());
      setState(() {
        times = PrayerTimes(coordinates, date, params);
        locationName = cachedName ?? 'الموقع المحفوظ (${cachedLoc.$1.toStringAsFixed(2)})';
        error = null;
      });
    } else {
      setState(() {
        error = null;
        times = null;
        pos = null;
        locationName = null;
      });
    }

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (cachedLoc == null) {
          setState(() => error = 'خدمة الموقع مغلقة. شغّل GPS ثم اضغط تحديث.');
        }
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        if (cachedLoc == null) {
          setState(() => error = 'تم رفض إذن الموقع.');
        }
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        if (cachedLoc == null) {
          setState(() => error = 'إذن الموقع مرفوض نهائيًا. افتح الإعدادات وفعّله.');
        }
        return;
      }

      LocationSettings settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        settings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
          forceLocationManager: true,
        );
      }

      Position? p;
      try {
        p = await Geolocator.getCurrentPosition(locationSettings: settings);
      } on TimeoutException {
        p = await Geolocator.getLastKnownPosition();
      }

      if (p == null) {
        if (cachedLoc == null) {
          setState(() => error = 'لم نستطع الحصول على موقعك. جرّب فتح GPS ثم تحديث.');
        }
        return;
      }
      final currentPos = p;

      // احفظ الموقع + طريقة الحساب (لازم عشان الجدولة الطويلة)
      await PrayerSettingsStorage.setLocation(lat: currentPos.latitude, lon: currentPos.longitude);
      await PrayerSettingsStorage.setMethodKey(methodKey);

      final coordinates = Coordinates(currentPos.latitude, currentPos.longitude);
      final params = _paramsFromKey(methodKey)..madhab = Madhab.shafi;
      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);

      if (mounted) {
        setState(() {
          pos = p;
          times = prayerTimes;
          error = null;
        });
      }

      // Try reverse geocoding to get location name
      try {
        await setLocaleIdentifier('ar');
        final placemarks = await placemarkFromCoordinates(currentPos.latitude, currentPos.longitude);
        if (placemarks.isNotEmpty) {
          final pmark = placemarks.first;
          final parts = [
            pmark.name,
            pmark.subLocality,
            pmark.locality, 
            pmark.subAdministrativeArea, 
            pmark.administrativeArea
          ].where((s) => s != null && s.isNotEmpty).cast<String>().toSet().toList();
          
          final digitRegExp = RegExp(r'[0-9٠-٩]');
          final filteredParts = parts
              .where((p) => p != pmark.country && 
                            p != pmark.postalCode && 
                            !p.contains('+') &&
                            !p.contains('/') &&
                            !p.contains('\\') &&
                            !digitRegExp.hasMatch(p))
              .toList();
          final name = filteredParts.isNotEmpty ? filteredParts.take(3).join('، ') : pmark.country;
          
          if (name != null) {
            await PrayerSettingsStorage.setLocationName(name);
          }
          if (mounted) {
            setState(() {
              locationName = name;
            });
          }
        } else {
          final fallbackName = 'موقع (${currentPos.latitude.toStringAsFixed(2)})';
          await PrayerSettingsStorage.setLocationName(fallbackName);
          if (mounted) {
            setState(() {
              locationName = fallbackName;
            });
          }
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
        final fallbackName = 'إحداثيات: ${currentPos.latitude.toStringAsFixed(2)}، ${currentPos.longitude.toStringAsFixed(2)}';
        await PrayerSettingsStorage.setLocationName(fallbackName);
        if (mounted) {
          setState(() {
            locationName = fallbackName;
          });
        }
      }

      // لو التنبيهات شغالة، جرّب جدولة/تجديد تلقائي
      await PrayerNotificationsScheduler.tryAutoReschedule();
    } catch (e) {
      if (cachedLoc == null) {
        setState(() => error = 'خطأ في تحديد الموقع/الحساب:\n$e');
      }
    }
  }

  String fmt(DateTime dt) => DateFormat('hh:mm a', 'ar').format(dt);

  Future<void> _reschedule() async {
    await PrayerSettingsStorage.setMethodKey(methodKey);
    await PrayerNotificationsScheduler.rescheduleFromSavedSettings(days: 14);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث جدولة التنبيهات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterEnabled = PrayerSettingsStorage.enabled;
    final soundEnabled = PrayerSettingsStorage.soundEnabled;
    final per = PrayerSettingsStorage.perPrayerEnabled;

    return GlassScaffold(
      title: 'مواقيت الصلاة',
      actions: [
        const HijriChip(),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _load();
          },
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('طريقة الحساب'),
                subtitle: Text(_methodLabel(methodKey)),
                trailing: const Icon(Icons.tune),
                onTap: () async {
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => _MethodPicker(current: methodKey),
                  );
                  if (selected == null) return;
                  setState(() => methodKey = selected);

                  // لو التنبيهات شغالة، غيّر الطريقة ثم جدولة جديدة
                  if (PrayerSettingsStorage.enabled) {
                    await _reschedule();
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            if (error != null) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: Geolocator.openLocationSettings,
                            child: const Text('إعدادات الموقع'),
                          ),
                          OutlinedButton(
                            onPressed: Geolocator.openAppSettings,
                            child: const Text('إعدادات التطبيق'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ] else if (times == null) ...[
              const Expanded(child: Center(child: CircularProgressIndicator()))
            ] else ...[
              Expanded(
                child: ListView(
                  cacheExtent: 500,
                  children: [
                    if (locationName != null)
                      Text(
                        'الموقع: $locationName',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black87,
                        ),
                      )
                    else if (pos != null)
                      Text(
                        'الموقع: ${pos!.latitude.toStringAsFixed(4)}, ${pos!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // ===== Master + Sound switches =====
                    Card(
                      child: SwitchListTile(
                        title: const Text('تفعيل تنبيهات الأذان'),
                        value: masterEnabled,
                        onChanged: (v) async {
                          await PrayerSettingsStorage.setEnabled(v);
                          setState(() {});
                          if (!v) {
                            await NotificationService.cancelAll();
                          } else {
                            await _reschedule();
                          }
                        },
                      ),
                    ),
                    Card(
                      child: SwitchListTile(
                        title: const Text('تشغيل صوت الأذان'),
                        value: soundEnabled,
                        onChanged: !masterEnabled
                            ? null
                            : (v) async {
                                await PrayerSettingsStorage.setSoundEnabled(v);
                                setState(() {});
                                await _reschedule();
                              },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ===== Prayer rows with toggles =====
                    _PrayerTile(
                      title: 'الفجر',
                      time: fmt(times!.fajr),
                      enabled: per[PrayerSettingsStorage.fajr] ?? true,
                      masterEnabled: masterEnabled,
                      onToggle: (v) async {
                        await PrayerSettingsStorage.setPrayerEnabled(
                            PrayerSettingsStorage.fajr, v);
                        setState(() {});
                        await _reschedule();
                      },
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('الشروق'),
                        subtitle: Text(fmt(times!.sunrise)),
                        trailing: const Icon(
                          Icons.wb_sunny_outlined,
                          color: Color(0xFFC5A85C),
                        ),
                      ),
                    ),
                    _PrayerTile(
                      title: 'الظهر',
                      time: fmt(times!.dhuhr),
                      enabled: per[PrayerSettingsStorage.dhuhr] ?? true,
                      masterEnabled: masterEnabled,
                      onToggle: (v) async {
                        await PrayerSettingsStorage.setPrayerEnabled(
                            PrayerSettingsStorage.dhuhr, v);
                        setState(() {});
                        await _reschedule();
                      },
                    ),
                    _PrayerTile(
                      title: 'العصر',
                      time: fmt(times!.asr),
                      enabled: per[PrayerSettingsStorage.asr] ?? true,
                      masterEnabled: masterEnabled,
                      onToggle: (v) async {
                        await PrayerSettingsStorage.setPrayerEnabled(
                            PrayerSettingsStorage.asr, v);
                        setState(() {});
                        await _reschedule();
                      },
                    ),
                    _PrayerTile(
                      title: 'المغرب',
                      time: fmt(times!.maghrib),
                      enabled: per[PrayerSettingsStorage.maghrib] ?? true,
                      masterEnabled: masterEnabled,
                      onToggle: (v) async {
                        await PrayerSettingsStorage.setPrayerEnabled(
                            PrayerSettingsStorage.maghrib, v);
                        setState(() {});
                        await _reschedule();
                      },
                    ),
                    _PrayerTile(
                      title: 'العشاء',
                      time: fmt(times!.isha),
                      enabled: per[PrayerSettingsStorage.isha] ?? true,
                      masterEnabled: masterEnabled,
                      onToggle: (v) async {
                        await PrayerSettingsStorage.setPrayerEnabled(
                            PrayerSettingsStorage.isha, v);
                        setState(() {});
                        await _reschedule();
                      },
                    ),

                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _methodLabel(String key) {
    switch (key) {
      case 'umm_al_qura':
        return 'أم القرى';
      case 'egyptian':
        return 'الهيئة المصرية';
      case 'karachi':
        return 'كراتشي';
      case 'dubai':
        return 'دبي';
      case 'mwl':
      default:
        return 'رابطة العالم الإسلامي';
    }
  }
}

class _PrayerTile extends StatelessWidget {
  final String title;
  final String time;
  final bool enabled;
  final bool masterEnabled;
  final Future<void> Function(bool) onToggle;

  const _PrayerTile({
    required this.title,
    required this.time,
    required this.enabled,
    required this.masterEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(time),
        value: enabled,
        onChanged: !masterEnabled ? null : (v) => onToggle(v),
      ),
    );
  }
}

class _MethodPicker extends StatelessWidget {
  final String current;
  const _MethodPicker({required this.current});

  @override
  Widget build(BuildContext context) {
    final items = const <(String, String)>[
      ('mwl', 'رابطة العالم الإسلامي'),
      ('umm_al_qura', 'أم القرى'),
      ('egyptian', 'الهيئة المصرية'),
      ('karachi', 'كراتشي'),
      ('dubai', 'دبي'),
    ];

    return ListView(
      children: [
        const ListTile(title: Text('اختر طريقة الحساب')),
        ...items.map((it) {
          return RadioListTile<String>(
            value: it.$1,
            groupValue: current,
            onChanged: (v) => Navigator.pop(context, v),
            title: Text(it.$2),
          );
        }),
      ],
    );
  }
}