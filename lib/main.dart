// Premium Glassy & Gold UI Overhaul - Azkar Expansion
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'src/core/notifications/notification_service.dart';
import 'src/core/storage/local_store.dart';
import 'src/features/prayer/prayer_notifications_scheduler.dart';
import 'src/tasbeeh_app.dart';


// Global future to track services initialization without blocking app launch
late final Future<void> appInitFuture;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Kick off initializations in the background instantly!
  appInitFuture = _initServices();
  

  runApp(const ProviderScope(child: TasbeehApp()));
}

Future<void> _initServices() async {
  try {

    await Hive.initFlutter();
    await LocalStore.init();
    await NotificationService.init();
    await PrayerNotificationsScheduler.tryAutoReschedule();

    // Request location permission asynchronously after startup
    _requestLocationPermission();
  } catch (e, stack) {
    debugPrint("CRITICAL_INIT_ERROR: $e");
    debugPrint("CRITICAL_STACK: $stack");
  }
}

Future<void> _requestLocationPermission() async {
  try {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  } catch (_) {}
}