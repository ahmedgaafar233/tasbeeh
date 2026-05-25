import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/local_store.dart';
import '../ui/glass.dart';
import '../../features/hijri/hijri_page.dart';

class HijriChip extends StatelessWidget {
  const HijriChip({super.key});

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal('ar');

    return ValueListenableBuilder(
      valueListenable: LocalStore.hijriBox.listenable(),
      builder: (context, box, _) {
        final offset = (LocalStore.hijriBox.get('dayOffset') ?? 0) as int;
        final now = DateTime.now().add(Duration(days: offset));
        final h = HijriCalendar.fromDate(now);

        final text = '${h.hDay} ${h.longMonthName} ${h.hYear}هـ';

        return Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HijriPage()),
              );
            },
            child: ShinyGoldBorder(
              radius: 18,
              width: 2.2,
              child: GlassCard(
                radius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}