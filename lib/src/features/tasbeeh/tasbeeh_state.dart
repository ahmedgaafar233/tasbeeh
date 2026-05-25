class TasbeehState {
  final String text;
  final int count;
  final int? target;

  const TasbeehState({
    required this.text,
    required this.count,
    required this.target,
  });

  TasbeehState copyWith({
    String? text,
    int? count,
    int? target,
    bool clearTarget = false,
  }) {
    return TasbeehState(
      text: text ?? this.text,
      count: count ?? this.count,
      target: clearTarget ? null : (target ?? this.target),
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'count': count,
        'target': target,
      };

  static TasbeehState fromMap(Map map) {
    return TasbeehState(
      text: (map['text'] ?? 'سبحان الله').toString(),
      count: (map['count'] ?? 0) as int,
      target: map['target'] == null ? null : (map['target'] as int),
    );
  }
}