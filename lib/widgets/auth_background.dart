import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AuthBackgroundPainter(),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Draw circles in top-left area
    _drawCircle(canvas, paint, Offset(size.width * 0.1, size.height * 0.05), 15);
    _drawCircle(canvas, paint, Offset(size.width * 0.25, size.height * 0.02), 10);
    _drawCircle(canvas, paint, Offset(size.width * 0.4, size.height * 0.08), 20);
    _drawCircle(canvas, paint, Offset(size.width * 0.05, size.height * 0.15), 12);
    _drawCircle(canvas, paint, Offset(size.width * 0.2, size.height * 0.12), 8);
    _drawCircle(canvas, paint, Offset(size.width * 0.3, size.height * 0.18), 16);
    _drawCircle(canvas, paint, Offset(size.width * 0.15, size.height * 0.22), 14);
    _drawCircle(canvas, paint, Offset(size.width * 0.02, size.height * 0.25), 10);
    _drawCircle(canvas, paint, Offset(size.width * 0.28, size.height * 0.28), 18);
    _drawCircle(canvas, paint, Offset(size.width * 0.1, size.height * 0.35), 12);

    // Draw circles in bottom-right area
    _drawCircle(canvas, paint, Offset(size.width * 0.9, size.height * 0.95), 15);
    _drawCircle(canvas, paint, Offset(size.width * 0.75, size.height * 0.98), 10);
    _drawCircle(canvas, paint, Offset(size.width * 0.6, size.height * 0.92), 20);
    _drawCircle(canvas, paint, Offset(size.width * 0.95, size.height * 0.85), 12);
    _drawCircle(canvas, paint, Offset(size.width * 0.8, size.height * 0.88), 8);
    _drawCircle(canvas, paint, Offset(size.width * 0.7, size.height * 0.82), 16);
    _drawCircle(canvas, paint, Offset(size.width * 0.85, size.height * 0.78), 14);
    _drawCircle(canvas, paint, Offset(size.width * 0.98, size.height * 0.75), 10);
    _drawCircle(canvas, paint, Offset(size.width * 0.72, size.height * 0.72), 18);
    _drawCircle(canvas, paint, Offset(size.width * 0.9, size.height * 0.65), 12);
  }

  void _drawCircle(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
