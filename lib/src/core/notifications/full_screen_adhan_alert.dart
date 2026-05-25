import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui';
import 'notification_service.dart';

class AdhanSubtitle {
  final double startSeconds;
  final double endSeconds;
  final String text;

  const AdhanSubtitle({
    required this.startSeconds,
    required this.endSeconds,
    required this.text,
  });
}

const List<AdhanSubtitle> _standardSubtitles = [
  // adhan.mp3 = 172 seconds total - exact waveform synchronized timings
  AdhanSubtitle(startSeconds: 0,   endSeconds: 4,   text: "أستمع إلى الأذان..."),
  AdhanSubtitle(startSeconds: 4,   endSeconds: 15,  text: "اللهُ أَكْبَرُ، اللهُ أَكْبَر"),
  AdhanSubtitle(startSeconds: 15,  endSeconds: 33,  text: "اللهُ أَكْبَرُ، اللهُ أَكْبَر"),
  AdhanSubtitle(startSeconds: 33,  endSeconds: 47,  text: "أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا الله"),
  AdhanSubtitle(startSeconds: 47,  endSeconds: 63,  text: "أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا الله"),
  AdhanSubtitle(startSeconds: 63,  endSeconds: 78,  text: "أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ الله"),
  AdhanSubtitle(startSeconds: 78,  endSeconds: 95,  text: "أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ الله"),
  AdhanSubtitle(startSeconds: 95,  endSeconds: 119, text: "حَيَّ عَلَى الصَّلَاة"),
  AdhanSubtitle(startSeconds: 119, endSeconds: 142, text: "حَيَّ عَلَى الصَّلَاة"),
  AdhanSubtitle(startSeconds: 142, endSeconds: 152, text: "حَيَّ عَلَى الْفَلَاح"),
  AdhanSubtitle(startSeconds: 152, endSeconds: 159, text: "حَيَّ عَلَى الْفَلَاح"),
  AdhanSubtitle(startSeconds: 159, endSeconds: 163, text: "اللهُ أَكْبَرُ، اللهُ أَكْبَر"),
  AdhanSubtitle(startSeconds: 163, endSeconds: 172, text: "لَا إِلٰهَ إِلَّا الله"),
];

const List<AdhanSubtitle> _fajrSubtitles = [
  // adhan_fajr.mp3 = 293 seconds total
  AdhanSubtitle(startSeconds: 0,   endSeconds: 8,   text: "أستمع إلى أذان الفجر..."),
  AdhanSubtitle(startSeconds: 8,   endSeconds: 32,  text: "اللهُ أَكْبَرُ، اللهُ أَكْبَر"),
  AdhanSubtitle(startSeconds: 32,  endSeconds: 62,  text: "اللهُ أَكْبَرُ، اللهُ أَكْبَر"),
  AdhanSubtitle(startSeconds: 62,  endSeconds: 90,  text: "أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا الله"),
  AdhanSubtitle(startSeconds: 90,  endSeconds: 118, text: "أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا الله"),
  AdhanSubtitle(startSeconds: 118, endSeconds: 146, text: "أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ الله"),
  AdhanSubtitle(startSeconds: 146, endSeconds: 172, text: "أَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ الله"),
  AdhanSubtitle(startSeconds: 172, endSeconds: 196, text: "حَيَّ عَلَى الصَّلَاة"),
  AdhanSubtitle(startSeconds: 196, endSeconds: 216, text: "حَيَّ عَلَى الصَّلَاة"),
  AdhanSubtitle(startSeconds: 216, endSeconds: 236, text: "حَيَّ عَلَى الْفَلَاح"),
  AdhanSubtitle(startSeconds: 236, endSeconds: 255, text: "حَيَّ عَلَى الْفَلَاح"),
  AdhanSubtitle(startSeconds: 255, endSeconds: 267, text: "الصَّلَاةُ خَيْرٌ مِنَ النَّوْم"),
  AdhanSubtitle(startSeconds: 267, endSeconds: 278, text: "الصَّلَاةُ خَيْرٌ مِنَ النَّوْم"),
  AdhanSubtitle(startSeconds: 278, endSeconds: 287, text: "اللهُ أَكْبَرُ، اللهُ أَكْبَر"),
  AdhanSubtitle(startSeconds: 287, endSeconds: 293, text: "لَا إِلٰهَ إِلَّا الله"),
];

class FullScreenAdhanAlert extends StatefulWidget {
  final String prayerName;

  const FullScreenAdhanAlert({
    super.key,
    required this.prayerName,
  });

  @override
  State<FullScreenAdhanAlert> createState() => _FullScreenAdhanAlertState();
}

class _FullScreenAdhanAlertState extends State<FullScreenAdhanAlert>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _backgroundController;
  late AnimationController _entranceController;
  
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  String _getSubtitleText(Duration elapsed) {
    final seconds = elapsed.inMilliseconds / 1000.0;
    final isFajr = widget.prayerName == 'الفجر';
    final timeline = isFajr ? _fajrSubtitles : _standardSubtitles;

    for (final sub in timeline) {
      if (seconds >= sub.startSeconds && seconds < sub.endSeconds) {
        return sub.text;
      }
    }
    return "لَا إِلٰهَ إِلَّا الله";
  }

  @override
  void initState() {
    super.initState();

    // Entrance Animation (Smooth fade & slide up)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _entranceSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.12), // Elegant slide up from below
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack, // Playful premium spring bounce
    ));

    _entranceController.forward();

    // Kaaba Pulsating Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Audio Ripples Animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Rotating background aura animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _backgroundController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _entranceFade,
      child: Stack(
        children: [
          // 1. Dynamic Glass Backdrop
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          // Rotating background lights
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _backgroundController.value * 2 * math.pi,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          const Color(0xFFC5A85C).withOpacity(0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.8],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Glassmorphism Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: const SizedBox(),
            ),
          ),

          // Main Alert Content Layer
          Positioned.fill(
            child: SafeArea(
              child: Material(
                type: MaterialType.transparency,
                child: SlideTransition(
                  position: _entranceSlide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                    // 2. Audio Ripple Effect + Pulsing Kaaba
                    SizedBox(
                      width: size.width * 0.75,
                      height: size.width * 0.75,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripples
                          AnimatedBuilder(
                            animation: _rippleController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(size.width * 0.75, size.width * 0.75),
                                painter: AdhanRipplePainter(
                                  progress: _rippleController.value,
                                ),
                              );
                            },
                          ),

                          // Pulsing Kaaba Box with 3D shadow & Golden borders
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale = 1.0 + (_pulseController.value * 0.08);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: size.width * 0.42,
                                  height: size.width * 0.42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFC5A85C).withOpacity(0.35),
                                        blurRadius: 30,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(0xFFC5A85C),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      color: const Color(0xFF1E2620),
                                      padding: const EdgeInsets.all(16),
                                      child: Image.asset(
                                        'assets/images/kaaba_glass_3d_clean.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.mosque,
                                            size: 80,
                                            color: Color(0xFFC5A85C),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 3. Beautiful Title and Synced Arabic Subtitles
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            'حان الآن موعد أذان ${widget.prayerName}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFC5A85C).withOpacity(0.95),
                              fontFamily: 'Cairo',
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<Duration>(
                            valueListenable: NotificationService.adhanPositionNotifier,
                            builder: (context, elapsed, _) {
                              final activeText = _getSubtitleText(elapsed);
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 0.25),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  activeText,
                                  key: ValueKey<String>(activeText),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Amiri',
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFFC5A85C),
                                        blurRadius: 15,
                                        offset: Offset(0, 0),
                                      ),
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // 4. Volume Control Slider
                    ValueListenableBuilder<double>(
                      valueListenable: NotificationService.adhanVolumeNotifier,
                      builder: (context, volume, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => NotificationService.setVolume((volume - 0.1).clamp(0.0, 1.0)),
                                child: const Icon(Icons.volume_down, color: Color(0xFFC5A85C), size: 24),
                              ),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return GestureDetector(
                                      onTapDown: (d) => NotificationService.setVolume(
                                        (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
                                      ),
                                      onHorizontalDragUpdate: (d) => NotificationService.setVolume(
                                        (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
                                      ),
                                      child: Container(
                                        height: 36,
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            // Track background
                                            Positioned.fill(
                                              child: Center(
                                                child: Container(
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Active track
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              bottom: 0,
                                              width: constraints.maxWidth * volume,
                                              child: Center(
                                                child: Container(
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFC5A85C),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Thumb
                                            Positioned(
                                              left: (constraints.maxWidth * volume - 8).clamp(0.0, constraints.maxWidth - 16),
                                              top: 0,
                                              bottom: 0,
                                              child: Center(
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(color: Colors.black26, blurRadius: 4),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () => NotificationService.setVolume((volume + 0.1).clamp(0.0, 1.0)),
                                child: const Icon(Icons.volume_up, color: Color(0xFFC5A85C), size: 24),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(volume * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // 5. Playback Stop & Dismiss Action Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFC5A85C),
                              Color(0xFFE5C880),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC5A85C).withOpacity(0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            NotificationService.stopAthan();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stop_circle_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'إيقاف الأذان وإغلاق',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],           // Column.children end
                ),             // Column end
              ),               // SlideTransition end
            ),                 // Material end
          ),                   // SafeArea end
        ),                     // Positioned.fill child end
      ],                       // Stack.children end
    ),                         // Stack end
  );                           // FadeTransition end
  }
}

class AdhanRipplePainter extends CustomPainter {
  final double progress;

  AdhanRipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final currentProgress = (progress + (i / 3)) % 1.0;
      final radius = currentProgress * maxRadius;
      final opacity = (1.0 - currentProgress) * 0.45;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFC5A85C).withOpacity(opacity),
            const Color(0xFFC5A85C).withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);

      // Stroke outline ring
      final strokePaint = Paint()
        ..color = const Color(0xFFC5A85C).withOpacity(opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AdhanRipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
