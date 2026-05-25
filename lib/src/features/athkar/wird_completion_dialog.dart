import 'package:flutter/material.dart';

class WirdCompletionDialog extends StatefulWidget {
  final String categoryTitle;
  const WirdCompletionDialog({super.key, required this.categoryTitle});

  @override
  State<WirdCompletionDialog> createState() => _WirdCompletionDialogState();
}

class _WirdCompletionDialogState extends State<WirdCompletionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark 
                ? const Color(0xFF0F172A).withOpacity(0.85) // Dark glassmorphic background
                : const Color(0xFFFFFFFF).withOpacity(0.9), // Light glassmorphic background
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.4), // Elegant gold border
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(isDark ? 0.15 : 0.08),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with glowing golden halo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.stars,
                  size: 64,
                  color: Color(0xFFFFD700), // Glowing gold icon
                ),
              ),
              const SizedBox(height: 24),

              // Title in beautiful gold typography
              Text(
                'بارك الله فيك',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFFFD37A) : const Color(0xFF8B6B0D),
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFD700).withOpacity(isDark ? 0.4 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message with perfect readability and high-contrast
              Text(
                'هنيئاً لك.. حُصنت بذكر الله\nفي ${widget.categoryTitle}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Premium glowing gold gradient button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B6B0D), // goldDeep
                        Color(0xFFC9A227), // goldMain
                        Color(0xFFFFD37A), // goldLight
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'الحمد لله',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
