import 'package:flutter/material.dart';

import 'features/athkar/athkar_page.dart';
import 'features/more/more_page.dart';
import 'features/prayer/prayer_page.dart';
import 'features/qibla/qibla_page.dart';
import 'features/quran/quran_page.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/glass_scaffold.dart';
import 'core/services/occasion_service.dart';
import 'features/home/occasion_dialog.dart';
import 'features/home/eid_celebration_dialog.dart';
import 'core/notifications/prayer_foreground_monitor.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final pages = const [
    AthkarPage(),
    PrayerPage(),
    QiblaPage(),
    QuranPage(),
    MorePage(),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint("APPSHELL_INIT_START");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Start monitoring prayer times
      PrayerForegroundMonitor.start(context);

      final occasion = await OccasionService.checkOccasion();
      if (occasion != null && mounted) {
        final isEid = occasion.id == 'eid_fitr' || occasion.id == 'eid_adha';
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => isEid
              ? EidCelebrationDialog(occasion: occasion)
              : OccasionDialog(occasion: occasion),
        );
        OccasionService.markAsShown(occasion);
      }
    });
  }

  @override
  void dispose() {
    PrayerForegroundMonitor.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showAppBar: false,
      body: Scaffold(
        backgroundColor: Colors.transparent, // Crucial: let the GlassScaffold background through
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.goldMain.withOpacity(0.2), width: 0.5)),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.menu_book), label: 'الأذكار'),
              NavigationDestination(icon: Icon(Icons.mosque), label: 'الصلاة'),
              NavigationDestination(icon: Icon(Icons.explore), label: 'القبلة'),
              NavigationDestination(icon: Icon(Icons.auto_stories), label: 'القرآن'),
              NavigationDestination(icon: Icon(Icons.more_horiz), label: 'المزيد'),
            ],
          ),
        ),
      ),
    );
  }
}