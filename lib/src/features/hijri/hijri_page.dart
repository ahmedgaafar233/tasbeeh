import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/storage/local_store.dart';

class HijriPage extends StatefulWidget {
  const HijriPage({super.key});

  @override
  State<HijriPage> createState() => _HijriPageState();
}

class _HijriPageState extends State<HijriPage> {
  int offset = (LocalStore.hijriBox.get('dayOffset') ?? 0) as int;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar'); // عرض أسماء الشهور بالعربي
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().add(Duration(days: offset));
    final h = HijriCalendar.fromDate(now);

    return Scaffold(
      appBar: AppBar(title: const Text('التاريخ الهجري')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('اليوم (هجري)'),
                subtitle: Text('${h.hDay} ${h.longMonthName} ${h.hYear} هـ'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('التاريخ الميلادي'),
                subtitle: Text(
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تصحيح يوم (اختياري)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _setOffset(offset - 1),
                          child: const Text('- 1'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => _setOffset(0),
                          child: const Text('0'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => _setOffset(offset + 1),
                          child: const Text('+ 1'),
                        ),
                        const Spacer(),
                        Text('الحالي: $offset'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setOffset(int v) {
    setState(() => offset = v.clamp(-2, 2));
    LocalStore.hijriBox.put('dayOffset', offset);
  }
}