import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui/circular_progress_counter.dart';
import '../../core/ui/glass_scaffold.dart';
import 'athkar_data.dart';
import 'athkar_storage.dart';
import 'wird_completion_dialog.dart';

class DhikrDetailPage extends StatefulWidget {
  final DhikrItem dhikr;
  const DhikrDetailPage({super.key, required this.dhikr});

  @override
  State<DhikrDetailPage> createState() => _DhikrDetailPageState();
}

class _DhikrDetailPageState extends State<DhikrDetailPage> {
  late int current;
  late int target;
  List<DhikrItem> categoryDhikr = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCounterAndList();
  }

  void _loadCounterAndList() {
    final c = AthkarStorage.getCounter(
      widget.dhikr.id,
      widget.dhikr.categoryId,
      widget.dhikr.defaultTarget,
    );
    target = (c['target'] ?? widget.dhikr.defaultTarget) as int;
    current = ((c['current'] ?? 0) as int).clamp(0, target);
    
    // Load all dhikr in this category
    final custom = AthkarStorage.loadCustom();
    categoryDhikr = [...builtInDhikr, ...custom]
        .where((d) => d.categoryId == widget.dhikr.categoryId)
        .toList();
    
    // Find current index
    currentIndex = categoryDhikr.indexWhere((d) => d.id == widget.dhikr.id);
    if (currentIndex == -1) currentIndex = 0;
  }

  void persist() {
    AthkarStorage.setCounter(widget.dhikr.id, current: current, target: target);
  }

  Future<void> _navigateToNext() async {
    if (currentIndex + 1 < categoryDhikr.length) {
      // There's a next dhikr
      final nextDhikr = categoryDhikr[currentIndex + 1];
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DhikrDetailPage(dhikr: nextDhikr)),
      );
    } else {
      // Completed the wird! Show congratulation
      final category = builtInCategories.firstWhere(
        (c) => c.id == widget.dhikr.categoryId,
        orElse: () => const DhikrCategory('', 'الورد'),
      );
      
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WirdCompletionDialog(categoryTitle: category.title),
      );
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Return to list
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // Calculate wird progress
    int totalCompleted = 0;
    int totalTarget = 0;
    for (final d in categoryDhikr) {
      final c = AthkarStorage.getCounter(d.id, d.categoryId, d.defaultTarget);
      final count = (c['current'] ?? 0) as int;
      final t = (c['target'] ?? d.defaultTarget) as int;
      totalCompleted += count.clamp(0, t);
      totalTarget += t;
    }
    final wirdProgress = totalTarget <= 0 ? 0.0 : (totalCompleted / totalTarget).clamp(0.0, 1.0);

    return GlassScaffold(
      title: 'الذكر',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Wird progress text
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFC58A12).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assessment, size: 18, color: Color(0xFFC58A12)),
                  const SizedBox(width: 8),
                  Text(
                    'تقدم الورد: ${(wirdProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC58A12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Dhikr text card (Expanded - takes up all remaining space dynamically, scrollable)
            Expanded(
              child: Card(
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Text(
                        widget.dhikr.text,
                        style: const TextStyle(fontSize: 20, height: 1.8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 3. Count row (fixed height)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'العدد: $current / $target',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final newTarget = await _editTargetDialog(context, target);
                    if (newTarget == null) return;
                    setState(() {
                      target = newTarget;
                      current = current.clamp(0, target);
                    });
                    persist();
                  },
                  child: const Text('تعديل العدد'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Fixed-size Circular Counter Button (NEVER shrinks, NEVER moves!)
            Container(
              height: 250,
              alignment: Alignment.center,
              child: CircularProgressCounter(
                current: current,
                target: target,
                size: 220, // Stable fixed size that fits all phones
                onTap: () async {
                  if (current >= target) return;
                  
                  HapticFeedback.selectionClick();
                  SystemSound.play(SystemSoundType.click);

                  setState(() => current++);
                  persist();

                  if (current == target) {
                    // Completion Mega-Pulse
                    for(int i = 0; i < 3; i++) {
                       HapticFeedback.mediumImpact();
                       await Future.delayed(const Duration(milliseconds: 100));
                    }
                    
                    // Auto-navigate to next (snappy 150ms delay)
                    await Future.delayed(const Duration(milliseconds: 150));
                    if (!mounted) return;
                    await _navigateToNext();
                  }
                },
                centerChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'اضغط للعدّ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '$current',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() => current = 0);
                      persist();
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('إعادة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _editTargetDialog(BuildContext context, int initial) async {
    final c = TextEditingController(text: initial.toString());
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعديل العدد المطلوب'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'مثال: 33',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(c.text.trim());
              Navigator.pop(context, (v == null || v <= 0) ? initial : v);
            },
            child: const Text('حفظ'),
          )
        ],
      ),
    );
  }
}