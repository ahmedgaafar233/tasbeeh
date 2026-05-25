import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/storage/local_store.dart';
import '../../core/ui/universal_hijri_header.dart';
import '../../core/ui/glass.dart';
import '../../core/ui/glass_scaffold.dart';
import '../../core/theme/app_theme.dart';
import 'package:tasbeeh_app/src/core/ui/glass_scaffold.dart';
import 'athkar_data.dart';
import 'athkar_storage.dart';
import 'dhikr_detail_page.dart';
import 'new_dhikr_page.dart';

class AthkarPage extends StatelessWidget {
  const AthkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'الأذكار',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.goldMain,
        foregroundColor: Colors.black,
        tooltip: 'إضافة ذكر (أذكاري)',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewDhikrPage(categoryId: 'my')),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const UniversalHijriHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: builtInCategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final cat = builtInCategories[i];
                return GlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: ShinyGoldBorder(
                      radius: 12,
                      width: 1.5,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.black54 
                            : Colors.white70,
                        child: Icon(
                          _getCategoryIcon(cat.id),
                          color: AppTheme.goldMain,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(cat.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AthkarListPage(category: cat),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String id) {
    switch (id) {
      case 'morning': return Icons.wb_sunny_outlined;
      case 'evening': return Icons.nightlight_round;
      case 'post_prayer': return Icons.done_all;
      case 'masjed_home': return Icons.home_work_outlined;
      case 'travel_distress': return Icons.flight_takeoff;
      case 'various': return Icons.category_outlined;
      case 'sleep': return Icons.bedtime_outlined;
      case 'wakeup': return Icons.wb_twilight;
      case 'prophets': return Icons.auto_awesome;
      case 'roquia': return Icons.health_and_safety_outlined;
      default: return Icons.favorite_border;
    }
  }
}

class AthkarListPage extends StatelessWidget {
  final DhikrCategory category;
  const AthkarListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: category.title,
      actions: [
        IconButton(
          tooltip: 'إضافة ذكر هنا',
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NewDhikrPage(categoryId: category.id)),
          ),
        ),
      ],
      body: Column(
        children: [
          const UniversalHijriHeader(),
          if (category.id == 'my')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.goldMain, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'يمكنك إضافة أدعيتك المفضلة هنا',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: LocalStore.customDhikrBox.listenable(),
              builder: (context, _, __) {
                final custom = AthkarStorage.loadCustom();
                final all = [...builtInDhikr, ...custom]
                    .where((d) => d.categoryId == category.id)
                    .toList();

                if (all.isEmpty) {
                  return const Center(child: Text('لا يوجد أذكار هنا'));
                }

                return ValueListenableBuilder(
                  valueListenable: LocalStore.dhikrCountersBox.listenable(),
                  builder: (context, __, ___) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      cacheExtent: 400,
                      itemCount: all.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final d = all[i];
                        final c = AthkarStorage.getCounter(d.id, d.categoryId, d.defaultTarget);
                        final current = (c['current'] ?? 0) as int;
                        final target = (c['target'] ?? d.defaultTarget) as int;

                        return GlassCard(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(
                              d.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Amiri', fontSize: 16),
                            ),
                            subtitle: Text('العدد الحالي: $current / الهدف: $target'),
                            leading: Icon(Icons.format_quote, color: AppTheme.goldMain),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (d.isCustom)
                                  IconButton(
                                    tooltip: 'حذف',
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    onPressed: () => AthkarStorage.deleteCustom(d.id),
                                  ),
                                const Icon(Icons.chevron_left),
                              ],
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DhikrDetailPage(dhikr: d)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}