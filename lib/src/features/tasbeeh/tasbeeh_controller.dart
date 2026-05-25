import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/storage/local_store.dart';
import 'tasbeeh_state.dart';

final tasbeehProvider =
    NotifierProvider<TasbeehController, TasbeehState>(TasbeehController.new);

class TasbeehController extends Notifier<TasbeehState> {
  static const _key = 'tasbeeh_state';

  @override
  TasbeehState build() {
    final raw = LocalStore.appBox.get(_key);
    if (raw is Map) {
      return TasbeehState.fromMap(raw);
    }
    return const TasbeehState(text: 'سبحان الله', count: 0, target: null);
  }

  void _persist() {
    LocalStore.appBox.put(_key, state.toMap());
  }

  /// يرجع true لو وصل للـ target في هذه الضغطة
  bool increment() {
    HapticFeedback.lightImpact();
    final next = state.count + 1;
    state = state.copyWith(count: next);
    _persist();

    final t = state.target;
    return (t != null && next >= t);
  }

  void reset() {
    state = state.copyWith(count: 0);
    _persist();
  }

  void setText(String text) {
    state =
        state.copyWith(text: text.trim().isEmpty ? 'سبحان الله' : text.trim());
    _persist();
  }

  void setTarget(int? target) {
    if (target == null) {
      state = state.copyWith(clearTarget: true);
    } else {
      state = state.copyWith(target: target <= 0 ? 1 : target);
    }
    _persist();
  }

  void saveCurrent() {
    final id = const Uuid().v4();
    LocalStore.savedTasbeehBox.put(id, {
      'id': id,
      'text': state.text,
      'count': state.count,
      'target': state.target,
      'savedAt': DateTime.now().toIso8601String(),
    });
  }

  void loadFromSaved(Map item) {
    state = TasbeehState(
      text: (item['text'] ?? 'سبحان الله').toString(),
      count: (item['count'] ?? 0) as int,
      target: item['target'] == null ? null : (item['target'] as int),
    );
    _persist();
  }
}