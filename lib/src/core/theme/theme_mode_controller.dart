import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_store.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'themeMode'; // system / light / dark

  @override
  ThemeMode build() {
    if (!LocalStore.isInitialized) {
      return ThemeMode.system; // Fallback during splash before Hive is loaded
    }
    final raw = (LocalStore.appBox.get(_key) ?? 'system').toString();
    return _fromString(raw);
  }

  void refreshTheme() {
    if (LocalStore.isInitialized) {
      final raw = (LocalStore.appBox.get(_key) ?? 'system').toString();
      state = _fromString(raw);
    }
  }

  void setMode(ThemeMode mode) {
    state = mode;
    if (LocalStore.isInitialized) {
      LocalStore.appBox.put(_key, _toString(mode));
    }
  }

  ThemeMode _fromString(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system; // هنا default منطقي لأنه String ممكن يبقى أي حاجة
    }
  }

  String _toString(ThemeMode mode) {
    // هنا ممنوع default لأن ThemeMode enum وكل الحالات متغطية
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}