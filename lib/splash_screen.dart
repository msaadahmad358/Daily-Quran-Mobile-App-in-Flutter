import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  final String appTitle;
  final String subtitle;

  const SplashScreen({
    super.key,
    required this.onFinished,
    required this.appTitle,
    required this.subtitle,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF1A5F4A);
  static const _primaryLight = Color(0xFF2D7A62);
  static const _gold = Color(0xFFC9A96E);

  late AnimationController _master;
  late AnimationController _pulse;
  late Animation<double> _logoScale;
  late Animation<double> _fade;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _logoScale = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    );
    _slideUp = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    );

    _master.forward();

    Future<void>.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _master.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, _primaryLight, Color(0xFF134A3A)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _master,
            builder: (context, _) {
              return CustomPaint(
                painter: _SplashPatternPainter(progress: _master.value),
                child: const SizedBox.expand(),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1).animate(_logoScale),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final glow = 0.12 + _pulse.value * 0.08;
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: glow),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.45),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu_book_rounded,
                            size: 56,
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(_slideUp),
                    child: Column(
                      children: [
                        Text(
                          widget.appTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 14,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fade,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48, 0, 48, 36),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: AnimatedBuilder(
                            animation: _master,
                            builder: (context, _) {
                              return LinearProgressIndicator(
                                value: _master.value.clamp(0.05, 1.0),
                                minHeight: 3,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                color: _gold,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashPatternPainter extends CustomPainter {
  final double progress;

  _SplashPatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cx = size.width * 0.85;
    final cy = size.height * 0.12;
    for (var i = 0; i < 6; i++) {
      final r = 40.0 + i * 28 + progress * 12;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    final paint2 = Paint()
      ..color = const Color(0xFFC9A96E).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.72);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * (0.62 - progress * 0.02),
      size.width,
      size.height * 0.78,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint2);

    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + progress * 0.3;
      final ox = size.width * 0.08 + math.cos(angle) * 24;
      final oy = size.height * 0.22 + math.sin(angle) * 16;
      canvas.drawCircle(Offset(ox, oy), 3, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
