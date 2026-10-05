import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Screen 5: CustomPaint widget for Boarding Points Map
class BoardingMapPainter extends CustomPainter {
  final List<BoardingPoint> points;
  final BoardingPoint? selectedPoint;

  BoardingMapPainter({
    required this.points,
    required this.selectedPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Map Background
    final bgPaint = Paint()..color = const Color(0xFFE8ECEF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Parks / Green zones
    final parkPaint = Paint()..color = const Color(0xFFD0E7D2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 20, size.width * 0.35, size.height * 0.25),
        const Radius.circular(12),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.60, size.height * 0.55, size.width * 0.35, size.height * 0.35),
        const Radius.circular(12),
      ),
      parkPaint,
    );

    // 3. Water body / River curve
    final waterPaint = Paint()
      ..color = const Color(0xFFBEE3F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final waterPath = Path();
    waterPath.moveTo(0, size.height * 0.7);
    waterPath.cubicTo(
      size.width * 0.3,
      size.height * 0.85,
      size.width * 0.7,
      size.height * 0.45,
      size.width,
      size.height * 0.6,
    );
    canvas.drawPath(waterPath, waterPaint);

    // 4. Secondary Road Grids
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    // Horizontal roads
    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), roadPaint);

    // Vertical roads
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), roadPaint);

    // 5. Main Route Highway (Red line connecting boarding points)
    final routePaint = Paint()
      ..color = const Color(0xFFD84E55).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (points.isNotEmpty) {
      final routePath = Path();
      routePath.moveTo(points.first.mapX * size.width, points.first.mapY * size.height);
      for (int i = 1; i < points.length; i++) {
        routePath.lineTo(points[i].mapX * size.width, points[i].mapY * size.height);
      }
      canvas.drawPath(routePath, routePaint);
    }

    // 6. Draw Boarding Point Markers
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final pos = Offset(p.mapX * size.width, p.mapY * size.height);
      final isSelected = selectedPoint?.id == p.id;

      // Pulse ring for selected
      if (isSelected) {
        final glowPaint = Paint()
          ..color = const Color(0xFFD84E55).withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 22, glowPaint);
      }

      // Marker pin
      final pinPaint = Paint()
        ..color = isSelected ? const Color(0xFFD84E55) : const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSelected ? 12 : 9, pinPaint);

      // Inner white dot
      final innerDot = Paint()..color = Colors.white;
      canvas.drawCircle(pos, isSelected ? 5 : 3.5, innerDot);

      // Label with landmark
      final textSpan = TextSpan(
        text: '${p.name}\n(${p.time})',
        style: TextStyle(
          color: isSelected ? const Color(0xFFD84E55) : const Color(0xFF1E293B),
          fontSize: isSelected ? 11 : 9.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          backgroundColor: Colors.white.withValues(alpha: 0.85),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + 14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoardingMapPainter oldDelegate) {
    return oldDelegate.selectedPoint?.id != selectedPoint?.id || oldDelegate.points != points;
  }
}

/// Screen 10: CustomPaint widget for Full-Screen Live Bus Tracking
class LiveTrackingMapPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 along the route
  final bool isDeviated;
  final String origin;
  final String destination;
  final String nextStop;

  LiveTrackingMapPainter({
    required this.progress,
    required this.isDeviated,
    required this.origin,
    required this.destination,
    required this.nextStop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Rich Modern Map Background & Terrain
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle grid pattern for map coordinates
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Forest / Green terrain reserves
    final greenPaint = Paint()..color = const Color(0xFFDCFCE7).withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.15, size.width * 0.35, size.height * 0.25),
        const Radius.circular(24),
      ),
      greenPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.55, size.width * 0.38, size.height * 0.30),
        const Radius.circular(24),
      ),
      greenPaint,
    );

    // Blue Lake / River
    final riverPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.60);
    riverPath.cubicTo(
      size.width * 0.35,
      size.height * 0.70,
      size.width * 0.65,
      size.height * 0.30,
      size.width,
      size.height * 0.45,
    );
    canvas.drawPath(riverPath, riverPaint);

    // 2. High-precision Highway Waypoints (Connecting Origin to Destination)
    final waypoints = [
      Offset(size.width * 0.18, size.height * 0.82), // Origin: Bengaluru
      Offset(size.width * 0.32, size.height * 0.64), // Hosur Toll Plaza
      Offset(size.width * 0.48, size.height * 0.50), // Midway Oasis Halt
      Offset(size.width * 0.68, size.height * 0.36), // Vellore Bypass
      Offset(size.width * 0.82, size.height * 0.18), // Destination: Chennai
    ];

    // Scheduled Route Path
    final routePath = Path();
    routePath.moveTo(waypoints[0].dx, waypoints[0].dy);
    for (int i = 1; i < waypoints.length; i++) {
      routePath.lineTo(waypoints[i].dx, waypoints[i].dy);
    }

    // Outer Glow / Casing for Highway
    final highwayGlow = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, highwayGlow);

    final roadCasing = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, roadCasing);

    // Active Highway Lane (Bright Blue or Emerald)
    final scheduledRoutePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, scheduledRoutePaint);

    // Dashed Center Divider
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 0; i < waypoints.length - 1; i++) {
      final p1 = waypoints[i];
      final p2 = waypoints[i + 1];
      final dist = (p2 - p1).distance;
      const step = 14.0;
      for (double d = 0; d < dist; d += step) {
        final start = Offset.lerp(p1, p2, d / dist)!;
        final end = Offset.lerp(p1, p2, (d + 6) / dist)!;
        canvas.drawLine(start, end, dashPaint);
      }
    }

    // 3. Draw Route Stops and Waypoints
    final stopLabels = [
      'Origin: $origin',
      '$origin Toll Plaza',
      'Midway Oasis Halt',
      'Near $destination Bypass',
      'Destination: $destination',
    ];

    for (int i = 0; i < waypoints.length; i++) {
      final pt = waypoints[i];
      final isEndpoint = (i == 0 || i == waypoints.length - 1);

      // Outer ring
      final ringPaint = Paint()
        ..color = isEndpoint ? const Color(0xFFD84E55) : const Color(0xFF0F172A)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, isEndpoint ? 10 : 7, ringPaint);
      canvas.drawCircle(pt, isEndpoint ? 5 : 3.5, Paint()..color = Colors.white);

      // Label
      _drawWaypointCard(canvas, pt, stopLabels[i], isEndpoint: isEndpoint, isTop: i % 2 != 0);
    }

    // 4. Calculate Bus Position along route
    Offset currentBusPos;
    double headingAngle = -0.785;

    if (isDeviated) {
      final branchStart = waypoints[2];
      final deviatedTarget = Offset(size.width * 0.28, size.height * 0.32);

      // Off-route dashed red trail
      final detourPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawLine(branchStart, deviatedTarget, detourPaint);

      currentBusPos = Offset.lerp(branchStart, deviatedTarget, 0.88)!;
      headingAngle = -2.35;

      // Deviation warning beacon at bus location
      final warningBeacon = Paint()
        ..color = Colors.red.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentBusPos, 35, warningBeacon);
    } else {
      final totalSegments = waypoints.length - 1;
      final scaledProgress = (progress.clamp(0.0, 1.0)) * totalSegments;
      final currentSegment = scaledProgress.floor().clamp(0, totalSegments - 1);
      final segmentProgress = scaledProgress - currentSegment;

      final startPt = waypoints[currentSegment];
      final endPt = waypoints[currentSegment + 1];

      currentBusPos = Offset.lerp(startPt, endPt, segmentProgress)!;
      headingAngle = atan2(endPt.dy - startPt.dy, endPt.dx - startPt.dx);
    }

    // 5. Radar Pulse Waves around Live Bus
    final pulsePaint = Paint()
      ..color = (isDeviated ? Colors.red : const Color(0xFFD84E55)).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentBusPos, 28, pulsePaint);

    final pulseRing = Paint()
      ..color = (isDeviated ? Colors.red : const Color(0xFFD84E55)).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(currentBusPos, 28, pulseRing);

    // 6. Draw 3D-styled Bus Marker
    canvas.save();
    canvas.translate(currentBusPos.dx, currentBusPos.dy);
    canvas.rotate(headingAngle + (pi / 2));

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(2, 2), width: 24, height: 40),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // Bus Body
    final busBodyPaint = Paint()..color = isDeviated ? const Color(0xFFDC2626) : const Color(0xFFD84E55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 24, height: 40),
        const Radius.circular(6),
      ),
      busBodyPaint,
    );

    // Roof stripe
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 26),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );

    // Windshield (Front glass)
    final glassPaint = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -12), width: 18, height: 7),
        const Radius.circular(3),
      ),
      glassPaint,
    );

    // Rear glass
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 14), width: 16, height: 4),
        const Radius.circular(2),
      ),
      glassPaint,
    );

    // Headlights beams
    final beamPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-8, -20), 3, beamPaint);
    canvas.drawCircle(const Offset(8, -20), 3, beamPaint);

    canvas.restore();
  }

  void _drawWaypointCard(Canvas canvas, Offset pos, String text, {required bool isEndpoint, required bool isTop}) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: isEndpoint ? const Color(0xFFD84E55) : const Color(0xFF0F172A),
        fontSize: isEndpoint ? 11.5 : 10,
        fontWeight: isEndpoint ? FontWeight.bold : FontWeight.w600,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(pos.dx, isTop ? pos.dy - 18 : pos.dy + 18),
        width: tp.width + 16,
        height: tp.height + 8,
      ),
      const Radius.circular(6),
    );

    // Card background
    canvas.drawRRect(cardRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = isEndpoint ? const Color(0xFFD84E55).withValues(alpha: 0.5) : const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    tp.paint(canvas, Offset(pos.dx - tp.width / 2, isTop ? pos.dy - 18 - tp.height / 2 : pos.dy + 18 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant LiveTrackingMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDeviated != isDeviated ||
        oldDelegate.nextStop != nextStop;
  }
}

/// Screen 8: CustomPaint QR Code generator (zero external packages)
class QrCodePainter extends CustomPainter {
  final String data;

  QrCodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    const int matrixSize = 21; // Standard 21x21 QR Version 1 grid
    final double cellSize = size.width / matrixSize;
    final fillPaint = Paint()..color = Colors.black;

    // Helper to fill a cell
    void fillCell(int row, int col) {
      canvas.drawRect(
        Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
        fillPaint,
      );
    }

    // Helper to draw 7x7 corner finder pattern
    void drawFinderPattern(int startRow, int startCol) {
      // 7x7 outer square
      for (int r = 0; r < 7; r++) {
        for (int c = 0; c < 7; c++) {
          if (r == 0 || r == 6 || c == 0 || c == 6) {
            fillCell(startRow + r, startCol + c);
          } else if (r >= 2 && r <= 4 && c >= 2 && c <= 4) {
            fillCell(startRow + r, startCol + c); // 3x3 inner square
          }
        }
      }
    }

    // 2. Draw 3 standard corner position detection markers
    drawFinderPattern(0, 0); // Top-left
    drawFinderPattern(0, matrixSize - 7); // Top-right
    drawFinderPattern(matrixSize - 7, 0); // Bottom-left

    // 3. Timing patterns (Row 6 and Col 6)
    for (int i = 8; i < matrixSize - 8; i++) {
      if (i % 2 == 0) {
        fillCell(6, i);
        fillCell(i, 6);
      }
    }

    // 4. Deterministic data matrix dots based on data hash
    final hash = data.hashCode.abs();
    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        // Skip finder areas
        final inTopLeft = (r < 8 && c < 8);
        final inTopRight = (r < 8 && c >= matrixSize - 8);
        final inBottomLeft = (r >= matrixSize - 8 && c < 8);
        final isTiming = (r == 6 || c == 6);

        if (!inTopLeft && !inTopRight && !inBottomLeft && !isTiming) {
          // Generate deterministic pseudo-random module based on cell coordinate and data
          final cellHash = (hash + (r * 37) + (c * 19) + (r * c)) % 100;
          if (cellHash % 2 == 0) {
            fillCell(r, c);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrCodePainter oldDelegate) => oldDelegate.data != data;
}
