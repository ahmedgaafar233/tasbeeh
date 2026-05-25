// dart:ui removed — BackdropFilter dropped for scroll performance
import 'package:flutter/material.dart';

class Glass {
  // Gold jewelry shine (قوي جدًا)
  static const List<Color> goldShine = [
    Color(0xFFFFFFFF),
    Color(0xFFFFF2C2),
    Color(0xFFFFD56A),
    Color(0xFFC58A12),
    Color(0xFFFFE08A),
    Color(0xFFFFFFFF),
  ];

  static Color tintFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // بدل الأبيض الشفاف (اللي بيخلّي كل حاجة "شبح") هنستخدم سطح أقوى:
    // Dark: أسود بلّوري
    // Light: أبيض بلّوري
    return isDark
        ? const Color(0xFF0D111A).withOpacity(0.70)
        : Colors.white.withOpacity(0.88);
  }

  static Color borderFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white.withOpacity(0.14) : Colors.black.withOpacity(0.06);
  }

  static Color highlightFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white.withOpacity(0.20) : Colors.white.withOpacity(0.55);
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double radius;
  final EdgeInsets padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10, // أقل = أوضح (مش شبح)
    this.radius = 26,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final tint = Glass.tintFor(context);
    final border = Glass.borderFor(context);
    final highlight = Glass.highlightFor(context);

    // No BackdropFilter — blur is GPU-expensive during scroll.
    // Solid tinted surface preserves the glassmorphism look without the lag.
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            spreadRadius: 0,
            color: Color(0x1A000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle sheen overlay (lightweight — no blur)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    colors: [
                      highlight,
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class ShinyGoldBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final double width;

  const ShinyGoldBorder({
    super.key,
    required this.child,
    this.radius = 26,
    this.width = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: SweepGradient(
          colors: Glass.goldShine,
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 10, spreadRadius: 1, color: Color(0x1B000000)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - width),
        child: child,
      ),
    );
  }
}