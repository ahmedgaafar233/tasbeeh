import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasbeeh_app/main.dart';
import '../../app_shell.dart';
import '../../core/theme/theme_mode_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  // Fade-in animation for the entire splash screen
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Dedicated tawaf circle animation controller
  late final AnimationController _tawafController;

  @override
  void initState() {
    super.initState();

    // 1. Fade-in animation (1.5s)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // 2. Tawaf circle animation (3.2s) - drives the arc from 0 to 1
    _tawafController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _tawafController.forward();

    // 3. Navigate when both tawaf completes AND services are ready
    Future.wait([
      _tawafController.forward().orCancel,
      appInitFuture,
    ]).then((_) {
      if (mounted) {
        ref.read(themeModeProvider.notifier).refreshTheme();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AppShell(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }).catchError((_) {
      // If animation was cancelled (widget disposed), do nothing
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tawafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // ─── 1. Background ───────────────────────────────────────────
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_bg_new.png',
                fit: BoxFit.cover,
              ),
            ),

            // ─── 2. Tawaf Circle + Kaaba ──────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _tawafController,
                builder: (context, child) {
                  final progress = _tawafController.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glowing gold aura that grows with progress
                      Container(
                        width: 218,
                        height: 218,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC5A85C)
                                  .withOpacity(0.15 + 0.25 * progress),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      // Tawaf counter-clockwise arc drawn via Canvas
                      SizedBox(
                        width: 218,
                        height: 218,
                        child: CustomPaint(
                          painter: TawafProgressPainter(
                            progress: progress,
                            arcColor: const Color(0xFFC5A85C),
                            trackColor:
                                Colors.white.withOpacity(0.07),
                            strokeWidth: 6.0,
                          ),
                        ),
                      ),

                      // Kaaba centerpiece
                      Container(
                        width: 148,
                        height: 148,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC5A85C)
                                .withOpacity(0.45),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC5A85C)
                                  .withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: const Color(0xFF0F172A),
                            padding: const EdgeInsets.all(18),
                            child: Image.asset(
                              'assets/images/kaaba_glass_3d_clean.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.mosque,
                                size: 72,
                                color: Color(0xFFC5A85C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ─── 3. Texts at the bottom ───────────────────────────────────
            Positioned(
              bottom: 80,
              left: 28,
              right: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App title "تَسْبِيح"
                  const Text(
                    'تَسْبِيح',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC5A85C),
                      fontFamily: 'Amiri',
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Color(0xFFC5A85C),
                          blurRadius: 28,
                          offset: Offset(0, 0),
                        ),
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Glassy gold Islamic reminder
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF3C4), // bright warm white-gold at top
                        Color(0xFFE2C275), // main gold in the middle
                        Color(0xFFC5A85C), // deeper gold at bottom
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: const Text(
                      'دائماً كن رطب اللسان بذكر الله',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                        height: 1.5,
                        color: Colors.white, // ShaderMask overrides this
                        shadows: [
                          Shadow(
                            color: Color(0xFF7A5C00),
                            blurRadius: 18,
                            offset: Offset(0, 4),
                          ),
                        ],
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Painter: Counter-clockwise Tawaf Progress Arc ─────────────────────
class TawafProgressPainter extends CustomPainter {
  final double progress;
  final Color arcColor;
  final Color trackColor;
  final double strokeWidth;

  const TawafProgressPainter({
    required this.progress,
    required this.arcColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw the full-circle track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    // Draw the gold arc counter-clockwise (negative sweep = counter-clockwise = Tawaf direction)
    canvas.drawArc(
      rect,
      -math.pi / 2,              // Start from the top (12 o'clock)
      -2 * math.pi * progress,   // Negative sweep = counter-clockwise
      false,
      Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant TawafProgressPainter old) =>
      old.progress != progress;
}
