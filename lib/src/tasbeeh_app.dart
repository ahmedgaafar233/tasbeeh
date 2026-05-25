import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/notifications/full_screen_adhan_alert.dart';
import 'features/splash/splash_page.dart';

class TasbeehApp extends ConsumerWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'تسبيح',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar')],
      locale: const Locale('ar'),

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,

      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              if (child != null) child,
              ValueListenableBuilder<String?>(
                valueListenable: NotificationService.adhanPlayingNotifier,
                builder: (context, adhanPlaying, _) {
                  if (adhanPlaying == null) return const SizedBox.shrink();
                  return FullScreenAdhanAlert(prayerName: adhanPlaying);
                },
              ),
            ],
          ),
        );
      },
      home: const SplashPage(),
    );
  }
}
