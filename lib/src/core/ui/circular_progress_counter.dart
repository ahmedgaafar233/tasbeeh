import 'package:flutter/material.dart';
import 'gold_counter_button.dart';

class CircularProgressCounter extends StatelessWidget {
  final int current;
  final int? target;
  final VoidCallback onTap;
  final double size;
  final Widget? centerChild;

  const CircularProgressCounter({
    super.key,
    required this.current,
    this.target,
    required this.onTap,
    this.size = 240,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final double? progress = (target == null || target == 0)
        ? null
        : (current / target!).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Progress Indicator (Gold aura)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC58A12)),
            ),
          ),
          // Interactive Counter Button inside
          GoldCounterButton(
            size: size - 30, // Maintains golden ratio gap
            onTap: onTap,
            child: centerChild ??
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$current',
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        fontFamily: 'Inter',
                        height: 1.1,
                      ),
                    ),
                    if (target != null && target! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'الهدف: $target',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
