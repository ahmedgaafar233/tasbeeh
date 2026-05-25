import 'package:flutter/material.dart';

import 'athkar_storage.dart';

class NewDhikrPage extends StatefulWidget {
  final String categoryId; // المكان اللي هنحفظ فيه الذكر
  const NewDhikrPage({super.key, this.categoryId = 'my'});

  @override
  State<NewDhikrPage> createState() => _NewDhikrPageState();
}

class _NewDhikrPageState extends State<NewDhikrPage> {
  final textC = TextEditingController();
  final targetC = TextEditingController();

  @override
  void dispose() {
    textC.dispose();
    targetC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة ذكر جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: textC,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'نص الذكر/الدعاء',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'العدد المطلوب',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
              onPressed: () {
                final text = textC.text.trim();
                final target = int.tryParse(targetC.text.trim()) ?? 33;

                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('اكتب نص الذكر أولًا')),
                  );
                  return;
                }

                AthkarStorage.addCustom(
                  text: text,
                  target: target <= 0 ? 1 : target,
                  categoryId: widget.categoryId,
                );

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}