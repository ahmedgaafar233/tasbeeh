import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_mode_controller.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final ctrl = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('المظهر')),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('حسب النظام'),
            value: ThemeMode.system,
            groupValue: mode,
            onChanged: (v) => ctrl.setMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('نهاري (فاتح)'),
            value: ThemeMode.light,
            groupValue: mode,
            onChanged: (v) => ctrl.setMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('ليلي (داكن)'),
            value: ThemeMode.dark,
            groupValue: mode,
            onChanged: (v) => ctrl.setMode(v!),
          ),
        ],
      ),
    );
  }
}