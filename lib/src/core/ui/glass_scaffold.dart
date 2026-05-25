import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool showAppBar;

  const GlassScaffold({
    super.key,
    required this.body,
    this.title = '',
    this.floatingActionButton,
    this.actions,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Crucial for nesting!
      extendBodyBehindAppBar: true,
      appBar: showAppBar
          ? AppBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.2)),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Highly Optimized Background Layer (Isolated GPU layer, never repaints during scroll)
          Positioned.fill(
            child: RepaintBoundary(
              child: Stack(
                children: [
                  // 1. Deep Background Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF010409),
                                  const Color(0xFF0F172A),
                                  const Color(0xFF1E293B),
                                ]
                              : [
                                  const Color(0xFFFFFFFF),
                                  const Color(0xFFF1F5F9),
                                  const Color(0xFFE2E8F0),
                                ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 2. Background Glow for Content
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            Colors.transparent,
                            Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 3. Highly Visible Islamic Star Pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _IslamicPatternPainter(
                        color: const Color(0xFFFFD700),
                        opacity: isDark ? 0.15 : 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(child: body),
        ],
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  _IslamicPatternPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 2.0 // Much thicker
      ..style = PaintingStyle.stroke;

    const spacing = 180.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final center = Offset(x, y);
        
        // Draw Octagram Star
        for (int i = 0; i < 2; i++) {
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(i * 45 * 3.14159 / 180);
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 60, height: 60), paint);
          canvas.restore();
        }
        
        // Center Detail
        canvas.drawCircle(center, 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
