import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'custom_map_paint.dart';

/// Mobile Native (Android & iOS) implementation for Interactive Map
/// Renders high-performance, touch-interactive map canvas with pinch-to-zoom,
/// panning, live bus animation, and boarding point selection.
class InteractiveGoogleMapView extends StatelessWidget {
  final String mode; // 'tracking' or 'boarding'
  final String apiKey;
  final String origin;
  final String destination;
  final double progress;
  final bool isDeviated;
  final String? selectedBpId;
  final void Function(String pointId)? onBoardingPointSelected;

  const InteractiveGoogleMapView({
    super.key,
    required this.mode,
    required this.apiKey,
    this.origin = 'Bengaluru',
    this.destination = 'Chennai',
    this.progress = 0.22,
    this.isDeviated = false,
    this.selectedBpId,
    this.onBoardingPointSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == 'tracking') {
      return InteractiveViewer(
        minScale: 0.7,
        maxScale: 3.5,
        child: CustomPaint(
          size: Size.infinite,
          painter: LiveTrackingMapPainter(
            progress: progress,
            isDeviated: isDeviated,
            origin: origin,
            destination: destination,
            nextStop: isDeviated ? 'Route Deviation Warning' : '$origin-$destination Highway Oasis',
          ),
        ),
      );
    } else {
      final points = MockData.getBoardingPointsForCity(origin);
      final selected = points.firstWhere(
        (p) => p.id == selectedBpId,
        orElse: () => points.first,
      );

      return CustomPaint(
        size: const Size(double.infinity, 230),
        painter: BoardingMapPainter(
          points: points,
          selectedPoint: selected,
        ),
      );
    }
  }
}
