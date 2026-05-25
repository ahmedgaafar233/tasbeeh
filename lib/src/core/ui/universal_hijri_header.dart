import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage/local_store.dart';
import 'glass.dart';
import '../theme/app_theme.dart';

class UniversalHijriHeader extends StatelessWidget {
  const UniversalHijriHeader({super.key});

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal('ar');

    return ValueListenableBuilder(
      valueListenable: LocalStore.hijriBox.listenable(),
      builder: (context, box, _) {
        final offset = (LocalStore.hijriBox.get('dayOffset') ?? 0) as int;
        final now = DateTime.now().add(Duration(days: offset));
        final h = HijriCalendar.fromDate(now);
        final dateText = '${h.hDay} ${h.longMonthName} ${h.hYear}هـ';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ShinyGoldBorder(
            radius: 12,
            width: 2.0,
            child: GlassCard(
              radius: 12,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppTheme.goldMain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.goldLight
                          : AppTheme.goldDeep,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
