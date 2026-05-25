import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/ui/glass.dart';
import '../../core/ui/glass_scaffold.dart';
import '../prayer/prayer_settings_storage.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  Position? _pos;
  String? _error;

  static const double _kaabaLat = 21.422487;
  static const double _kaabaLon = 39.826206;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _error = null;
      _pos = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        final cached = PrayerSettingsStorage.getLocation();
        if (cached != null) {
          setState(() {
            _pos = Position(
              latitude: cached.$1,
              longitude: cached.$2,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            );
            _error = null;
          });
          return;
        }
        setState(() => _error = 'خدمة الموقع مغلقة. شغّل GPS ثم أعد المحاولة.');
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        final cached = PrayerSettingsStorage.getLocation();
        if (cached != null) {
          setState(() {
            _pos = Position(
              latitude: cached.$1,
              longitude: cached.$2,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            );
            _error = null;
          });
          return;
        }
        setState(() => _error = 'تم رفض إذن الموقع. فعّله من إعدادات الجهاز.');
        return;
      }

      final p = await Geolocator.getCurrentPosition();
      setState(() => _pos = p);
      await PrayerSettingsStorage.setLocation(lat: p.latitude, lon: p.longitude);
    } catch (e) {
      final cached = PrayerSettingsStorage.getLocation();
      if (cached != null) {
        setState(() {
          _pos = Position(
            latitude: cached.$1,
            longitude: cached.$2,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
          _error = null;
        });
        return;
      }
      setState(() => _error = 'حدث خطأ: $e');
    }
  }

  double _bearingToKaaba(double lat, double lon) {
    final phi1 = lat * math.pi / 180.0;
    final phi2 = _kaabaLat * math.pi / 180.0;
    final dLon = (_kaabaLon - lon) * math.pi / 180.0;

    final y = math.sin(dLon) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLon);

    final theta = math.atan2(y, x);
    return (theta * 180.0 / math.pi + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = _pos;

    return GlassScaffold(
      title: 'اتجاه القبلة',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLocation),
      ],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : p == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<CompassEvent>(
                      stream: FlutterCompass.events,
                      builder: (context, snap) {
                        final heading = snap.data?.heading;
                        if (heading == null) {
                          return const Center(
                            child: Text('البوصلة غير متاحة على هذا الجهاز'),
                          );
                        }

                        final qibla = _bearingToKaaba(p.latitude, p.longitude);
                        final diffRad = (qibla - heading) * math.pi / 180.0;

                        return Column(
                          children: [
                            ShinyGoldBorder(
                              radius: 28,
                              child: GlassCard(
                                blur: 8,
                                radius: 28,
                                child: Column(
                                  children: [
                                    Text(
                                      'خلّي السهم الذهبي للأعلى',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'عندها ستكون مواجهًا للقبلة',
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: Center(
                                child: ShinyGoldBorder(
                                  radius: 240,
                                  width: 3.2,
                                  child: GlassCard(
                                    blur: 8,
                                    radius: 240,
                                    padding: const EdgeInsets.all(18),
                                    child: SizedBox(
                                      width: 330,
                                      height: 330,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CustomPaint(
                                            size: const Size(330, 330),
                                            painter: _CompassDialPainter(isDark: isDark),
                                          ),
                                          Transform.rotate(
                                            angle: diffRad,
                                            child: CustomPaint(
                                              size: const Size(270, 270),
                                              painter: _GoldArrowPainter(isDark: isDark),
                                            ),
                                          ),
                                          _KaabaCenter(isDark: isDark),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ShinyGoldBorder(
                              radius: 22,
                              child: GlassCard(
                                blur: 8,
                                radius: 22,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'القبلة: ${qibla.toStringAsFixed(0)}°\nاتجاهك: ${heading.toStringAsFixed(0)}°',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (_) => const AlertDialog(
                                          title: Text('المعايرة'),
                                          content: Text(
                                            'لو الاتجاه غير دقيق:\n'
                                            '- حرّك الهاتف حركة رقم 8\n'
                                            '- ابتعد عن المعادن/المغناطيس\n'
                                            '- جرّب في مكان مفتوح',
                                          ),
                                        ),
                                      ),
                                      child: const Text('معايرة'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

class _KaabaCenter extends StatelessWidget {
  final bool isDark;
  const _KaabaCenter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFD56A), Color(0xFFC58A12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 20, spreadRadius: 1, color: Color(0x33000000)),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDark ? const Color(0xFF0D111A) : Colors.white,
        ),
        child: const Icon(Icons.mosque, color: Color(0xFF1E7A5E)),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  _CompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.14);

    canvas.drawCircle(c, r - 12, thin);
    canvas.drawCircle(c, r - 40, thin);

    final tick = Paint()
      ..strokeWidth = 2.2
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.30);

    for (int i = 0; i < 360; i += 15) {
      final main = i % 90 == 0;
      final len = main ? 18.0 : 10.0;
      final a = i * math.pi / 180.0;
      final p1 = Offset(c.dx + (r - 18) * math.cos(a), c.dy + (r - 18) * math.sin(a));
      final p2 = Offset(c.dx + (r - 18 - len) * math.cos(a), c.dy + (r - 18 - len) * math.sin(a));
      canvas.drawLine(p1, p2, tick);
    }

    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.60),
    );

    void draw(String t, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    draw('N', Offset(c.dx, c.dy - (r - 64)));
    draw('E', Offset(c.dx + (r - 64), c.dy));
    draw('S', Offset(c.dx, c.dy + (r - 64)));
    draw('W', Offset(c.dx - (r - 64), c.dy));
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _GoldArrowPainter extends CustomPainter {
  final bool isDark;
  _GoldArrowPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: c, width: 240, height: 280);

    final gold = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFFD56A), Color(0xFFC58A12)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.black.withOpacity(isDark ? 0.35 : 0.18);

    final shadow = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(isDark ? 0.22 : 0.12);

    final path = Path();
    final tip = Offset(c.dx, c.dy - 120);
    final left = Offset(c.dx - 22, c.dy - 66);
    final right = Offset(c.dx + 22, c.dy - 66);
    final tailL = Offset(c.dx - 11, c.dy + 120);
    final tailR = Offset(c.dx + 11, c.dy + 120);

    path.moveTo(tip.dx, tip.dy);
    path.lineTo(right.dx, right.dy);
    path.lineTo(c.dx + 12, c.dy - 66);
    path.lineTo(tailR.dx, tailR.dy);
    path.lineTo(tailL.dx, tailL.dy);
    path.lineTo(c.dx - 12, c.dy - 66);
    path.lineTo(left.dx, left.dy);
    path.close();

    canvas.drawPath(path.shift(const Offset(2, 2)), shadow);
    canvas.drawPath(path, gold);
    canvas.drawPath(path, outline);

    final dot = Paint()..color = const Color(0xFF1E7A5E);
    canvas.drawCircle(Offset(c.dx, c.dy - 42), 7, dot);
  }

  @override
  bool shouldRepaint(covariant _GoldArrowPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}