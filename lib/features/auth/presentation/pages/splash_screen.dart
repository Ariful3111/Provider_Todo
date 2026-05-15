import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider_todo/core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────
  late final AnimationController _circleController;
  late final AnimationController _checkController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;

  // ── Circle scale + fade ────────────────────────────────────
  late final Animation<double> _circleScale;
  late final Animation<double> _circleFade;

  // ── Checkmark draw (stroke dash offset) ───────────────────
  late final Animation<double> _checkDraw;

  // ── Text slide + fade ──────────────────────────────────────
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // ── Subtle pulse on the logo ───────────────────────────────
  late final Animation<double> _pulse;

  static const _brandBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();

    // Circle pops in
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _circleScale = CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut,
    );
    _circleFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _circleController, curve: Curves.easeIn));

    // Checkmark draws itself
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkDraw = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));

    // Text slides up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Idle pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _runSequence();
  }

  // In _SplashScreenState — update _runSequence()
  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return; // ✅ check 1

    await _circleController.forward();
    if (!mounted) return; // ✅ check 2

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return; // ✅ check 3

    await _checkController.forward();
    if (!mounted) return; // ✅ check 4

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return; // ✅ check 5

    await _textController.forward();
    if (!mounted) return; // ✅ check 6

    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return; // ✅ check 7

    // ✅ Use GoRouter instead of Navigator
    context.go(AppRoutes.signIn);
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: big blue circle with checkmark ──────────
            ScaleTransition(
              scale: _circleScale,
              child: FadeTransition(
                opacity: _circleFade,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) =>
                      Transform.scale(scale: _pulse.value, child: child),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Blue filled circle
                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            color: _brandBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Animated checkmark
                        AnimatedBuilder(
                          animation: _checkDraw,
                          builder: (_, _) => CustomPaint(
                            size: const Size(46, 34),
                            painter: _CheckPainter(
                              progress: _checkDraw.value,
                              color: Colors.white,
                              strokeWidth: 7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Right: "to Do" text ────────────────────────────
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "to" — smaller, above
                    Text(
                      'to',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: _brandBlue,
                        height: 1.1,
                        letterSpacing: 1,
                      ),
                    ),
                    // "Do" with mini checkmark replacing the "o"
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'D',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: _brandBlue,
                            height: 1.0,
                          ),
                        ),
                        // Mini blue circle with checkmark (replaces "o")
                        Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: const BoxDecoration(
                            color: _brandBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _checkDraw,
                              builder: (_, _) => CustomPaint(
                                size: const Size(18, 13),
                                painter: _CheckPainter(
                                  progress: _checkDraw.value,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom painter: draws an animated checkmark ───────────────
class _CheckPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double strokeWidth;

  const _CheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Checkmark path: two segments
    // Segment 1: top-left down to the bottom notch  (~40% of total length)
    // Segment 2: bottom notch up to top-right        (~60%)
    final p1 = Offset(size.width * 0.08, size.height * 0.52);
    final p2 = Offset(size.width * 0.38, size.height * 0.88);
    final p3 = Offset(size.width * 0.92, size.height * 0.12);

    final totalLen = _dist(p1, p2) + _dist(p2, p3);
    final drawn = totalLen * progress;

    final path = Path();

    if (drawn <= _dist(p1, p2)) {
      // Still drawing first segment
      final t = drawn / _dist(p1, p2);
      final mid = Offset.lerp(p1, p2, t)!;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(mid.dx, mid.dy);
    } else {
      // First segment complete, drawing second
      final remaining = drawn - _dist(p1, p2);
      final t = remaining / _dist(p2, p3);
      final mid = Offset.lerp(p2, p3, t)!;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(mid.dx, mid.dy);
    }

    canvas.drawPath(path, paint);
  }

  double _dist(Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    return (dx * dx + dy * dy) == 0 ? 0.0001 : (dx * dx + dy * dy).abs();
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
