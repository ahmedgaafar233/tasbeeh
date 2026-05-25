import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../ui/glass.dart';

class PrayerTimeAlert extends StatelessWidget {
  final String prayerName;
  final VoidCallback onClose;

  const PrayerTimeAlert({
    super.key,
    required this.prayerName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        radius: 40,
        blur: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Glass Kaaba Image
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldMain.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/kaaba_glass_3d.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            
            // Text Content
            const Text(
              'حان الآن موعد',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            Text(
              'أذان $prayerName',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: AppTheme.goldMain,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'أقم صلاتك تنعم بحياتك',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.white60,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Close Button
            ShinyGoldBorder(
              radius: 20,
              width: 2,
              child: TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black26,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, String prayerName, VoidCallback onClosed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrayerTimeAlert(
        prayerName: prayerName,
        onClose: () {
          Navigator.pop(context);
          onClosed();
        },
      ),
    );
  }
}
