import 'package:uuid/uuid.dart';

import '../../core/storage/local_store.dart';
import 'athkar_data.dart';

class AthkarStorage {
  static List<DhikrItem> loadCustom() {
    final keys = LocalStore.customDhikrBox.keys.toList();
    final list = <DhikrItem>[];

    for (final k in keys) {
      final m = LocalStore.customDhikrBox.get(k);
      if (m is Map) {
        list.add(
          DhikrItem(
            id: (m['id'] ?? k).toString(),
            categoryId: (m['categoryId'] ?? 'my').toString(),
            text: (m['text'] ?? '').toString(),
            defaultTarget: (m['defaultTarget'] ?? 33) as int,
            isCustom: true,
          ),
        );
      }
    }
    return list;
  }

  static String addCustom({
    required String text,
    required int target,
    String categoryId = 'my',
  }) {
    final id = const Uuid().v4();

    LocalStore.customDhikrBox.put(id, {
      'id': id,
      'categoryId': categoryId,
      'text': text,
      'defaultTarget': target,
    });

    // Initialize counter for this dhikr
    LocalStore.dhikrCountersBox.put(id, {
      'current': 0,
      'target': target,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    return id;
  }

  static Map<String, dynamic> getCounter(String dhikrId, String categoryId, int defaultTarget) {
    final m = LocalStore.dhikrCountersBox.get(dhikrId);
    Map<String, dynamic> counterData;

    if (m is Map) {
      counterData = Map<String, dynamic>.from(m);
    } else {
      counterData = {
        'current': 0,
        'target': defaultTarget,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      LocalStore.dhikrCountersBox.put(dhikrId, counterData);
      return counterData;
    }

    // --- Smart Auto Reset Logic ---
    final updatedAtStr = counterData['updatedAt'] as String?;
    if (updatedAtStr == null) return counterData;

    final updatedAt = DateTime.tryParse(updatedAtStr);
    if (updatedAt == null) return counterData;

    final now = DateTime.now();
    bool shouldReset = false;

    final isSameDay = updatedAt.year == now.year && 
                      updatedAt.month == now.month && 
                      updatedAt.day == now.day;

    // 1. Daily Reset for ALL categories except 'my' (أذكاري / custom user athkar)
    if (!isSameDay && categoryId != 'my') {
      shouldReset = true;
    }
    // 2. Session Reset (Post-Prayer) - also resets if > 45 mins passed since last update
    else if (categoryId == 'post_prayer') {
      final difference = now.difference(updatedAt);
      if (difference.inMinutes > 45) {
        shouldReset = true;
      }
    }

    if (shouldReset) {
      counterData['current'] = 0;
      counterData['updatedAt'] = now.toIso8601String();
      LocalStore.dhikrCountersBox.put(dhikrId, counterData);
    }

    return counterData;
  }

  static void setCounter(String dhikrId, {required int current, required int target}) {
    LocalStore.dhikrCountersBox.put(dhikrId, {
      'current': current,
      'target': target,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  static void deleteCustom(String id) {
    LocalStore.customDhikrBox.delete(id);
    LocalStore.dhikrCountersBox.delete(id);
  }
}