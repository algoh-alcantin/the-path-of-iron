import 'package:flutter/material.dart';
import 'dart:math' as math;

class SamuraiIcons {
  static const IconData torii = Icons.architecture;
  static const IconData katana = Icons.sports_martial_arts;
  static const IconData mountainPath = Icons.trending_up;
  static const IconData scrollWisdom = Icons.auto_stories;
  static const IconData samuraiMask = Icons.face;
  static const IconData forge = Icons.local_fire_department;
  static const IconData meditation = Icons.self_improvement;
  static const IconData cherryBlossom = Icons.local_florist;
}

// Custom painted icons for more authentic samurai feel
class CustomSamuraiIcon extends StatelessWidget {
  final SamuraiIconType type;
  final double size;
  final Color color;

  const CustomSamuraiIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SamuraiIconPainter(type: type, color: color),
    );
  }
}

enum SamuraiIconType {
  katana,
  shuriken,
  torii,
  enso,
  mon,
}

class SamuraiIconPainter extends CustomPainter {
  final SamuraiIconType type;
  final Color color;

  SamuraiIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (type) {
      case SamuraiIconType.katana:
        _drawKatana(canvas, size, paint);
        break;
      case SamuraiIconType.shuriken:
        _drawShuriken(canvas, size, fillPaint);
        break;
      case SamuraiIconType.torii:
        _drawTorii(canvas, size, paint);
        break;
      case SamuraiIconType.enso:
        _drawEnso(canvas, size, paint);
        break;
      case SamuraiIconType.mon:
        _drawMon(canvas, size, fillPaint);
        break;
    }
  }

  void _drawKatana(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    
    // Blade
    path.moveTo(size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.8, size.height * 0.1);
    
    // Guard (tsuba)
    path.moveTo(size.width * 0.15, size.height * 0.85);
    path.lineTo(size.width * 0.25, size.height * 0.95);
    
    // Handle (tsuka)
    path.moveTo(size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.1, size.height * 1.0);
    
    canvas.drawPath(path, paint);
  }

  void _drawShuriken(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * (3.14159 / 180);
      final path = Path();
      
      // Create pointed star shape
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + radius * 0.7 * cos(angle),
        center.dy + radius * 0.7 * sin(angle),
      );
      path.lineTo(
        center.dx + radius * cos(angle + 0.5),
        center.dy + radius * sin(angle + 0.5),
      );
      path.lineTo(
        center.dx + radius * cos(angle - 0.5),
        center.dy + radius * sin(angle - 0.5),
      );
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawTorii(Canvas canvas, Size size, Paint paint) {
    // Top horizontal beam
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.2),
      paint,
    );
    
    // Second horizontal beam
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.4),
      paint,
    );
    
    // Left pillar
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.9),
      paint,
    );
    
    // Right pillar
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.9),
      paint,
    );
  }

  void _drawEnso(Canvas canvas, Size size, Paint paint) {
    // Zen circle - incomplete circle representing the beauty of imperfection
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    paint.strokeWidth = 3.0;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.2, // Start angle
      5.8, // Sweep angle (almost complete circle)
      false,
      paint,
    );
  }

  void _drawMon(Canvas canvas, Size size, Paint paint) {
    // Traditional Japanese family crest - simplified cherry blossom
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    // Five petals
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * (3.14159 / 180);
      final petalCenter = Offset(
        center.dx + radius * 0.6 * cos(angle),
        center.dy + radius * 0.6 * sin(angle),
      );
      
      canvas.drawCircle(petalCenter, radius * 0.3, paint);
    }
    
    // Center circle
    canvas.drawCircle(center, radius * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function for cos calculation
double cos(double angle) => math.cos(angle);

// Helper function for sin calculation  
double sin(double angle) => math.sin(angle);