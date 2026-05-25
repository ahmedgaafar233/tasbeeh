import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/storage/local_store.dart';
import '../../core/ui/circular_progress_counter.dart';
import '../../core/ui/hijri_chip.dart';
import 'tasbeeh_controller.dart';

class TasbeehPage extends ConsumerWidget {
  const TasbeehPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbeehProvider);
    final ctrl = ref.read(tasbeehProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التسبيح'),
        actions: [
          const HijriChip(),
          IconButton(
            tooltip: 'المحفوظات',
            icon: const Icon(Icons.bookmarks),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavedTasbeehPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DhikrInput(
              initial: state.text,
              onChanged: ctrl.setText,
            ),
            const SizedBox(height: 12),
            _TargetRow(
              currentTarget: state.target,
              onSetTarget: ctrl.setTarget,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: CircularProgressCounter(
                  current: state.count,
                  target: state.target,
                  size: 240,
                  onTap: () async {
                    final reached = ctrl.increment();
                    if (reached && context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('مبارك'),
                          content: const Text('تم إكمال التسبيح – بارك الله فيك'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('حسنًا'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  centerChild: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${state.count}',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      if (state.target != null && state.target! > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          'الهدف: ${state.target}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        'اضغط للعدّ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('تصفير'),
                    onPressed: ctrl.reset,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                    onPressed: () {
                      ctrl.saveCurrent();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ التسبيحة')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DhikrInput extends StatefulWidget {
  final String initial;
  final void Function(String) onChanged;

  const _DhikrInput({required this.initial, required this.onChanged});

  @override
  State<_DhikrInput> createState() => _DhikrInputState();
}

class _DhikrInputState extends State<_DhikrInput> {
  late final TextEditingController c;

  @override
  void initState() {
    super.initState();
    c = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'الذكر',
        border: OutlineInputBorder(),
      ),
      onSubmitted: widget.onChanged,
    );
  }
}

class _TargetRow extends StatelessWidget {
  final int? currentTarget;
  final void Function(int? target) onSetTarget;

  const _TargetRow({
    required this.currentTarget,
    required this.onSetTarget,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: currentTarget?.toString() ?? '');

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target (اختياري)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: () {
            final raw = controller.text.trim();
            if (raw.isEmpty) return onSetTarget(null);
            onSetTarget(int.tryParse(raw));
          },
          child: const Text('تطبيق'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => onSetTarget(null),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}

class SavedTasbeehPage extends ConsumerWidget {
  const SavedTasbeehPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(tasbeehProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('المحفوظات')),
      body: ValueListenableBuilder(
        valueListenable: LocalStore.savedTasbeehBox.listenable(),
        builder: (context, box, _) {
          final keys = box.keys.toList().reversed.toList();
          if (keys.isEmpty) {
            return const Center(child: Text('لا توجد تسبيحات محفوظة'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: keys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final key = keys[i];
              final item = box.get(key);
              if (item is! Map) return const SizedBox.shrink();

              final text = (item['text'] ?? '').toString();
              final count = (item['count'] ?? 0) as int;
              final target = item['target'];

              return Card(
                child: ListTile(
                  title: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('العدد: $count${target == null ? '' : ' / الهدف: $target'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'load') {
                        ctrl.loadFromSaved(item);
                        Navigator.pop(context);
                      }
                      if (v == 'delete') {
                        LocalStore.savedTasbeehBox.delete(key);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'load', child: Text('استئناف')),
                      PopupMenuItem(value: 'delete', child: Text('حذف')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}