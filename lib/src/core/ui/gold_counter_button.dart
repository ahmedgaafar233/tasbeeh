import 'package:flutter/material.dart';

import 'glass.dart';

class GoldCounterButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;
  final Widget child;

  const GoldCounterButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = 210,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ShinyGoldBorder(
        radius: size / 2,
        width: 3.2,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: ClipOval(
              child: Stack(
                children: [
                  // خلفية ذهبية لامعة (مركزها فاتح)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.2),
                          radius: 0.95,
                          colors: const [
                            Color(0xFFFFFFFF), // لمعان قوي
                            Color(0xFFFFF2C2),
                            Color(0xFFFFD56A),
                            Color(0xFFC58A12), // عمق
                          ],
                          stops: const [0.0, 0.35, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // لمعان إضافي (شيك)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.55),
                              Colors.transparent,
                              Colors.black.withOpacity(0.06),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // محتوى الزر (الرقم + النص)
                  Center(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}