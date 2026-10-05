import 'package:flutter/material.dart';
import '../models/models.dart';
import 'custom_map_paint.dart';
import 'interactive_google_map.dart';

class GoogleMapsConfig {
  /// Active Google Maps API Key provided by user
  static const String apiKey = 'AIzaSyAkP7n27ND7A5u2JyEJ7y_n8Yd_wtqe4GI';

  static String getBoardingPointsUrl({
    required List<BoardingPoint> points,
    required BoardingPoint? selectedPoint,
    String mapType = 'roadmap',
    int width = 600,
    int height = 350,
  }) {
    if (points.isEmpty) return '';

    final centerLat = selectedPoint?.latitude ?? points.first.latitude;
    final centerLng = selectedPoint?.longitude ?? points.first.longitude;

    final markers = StringBuffer();
    for (final p in points) {
      final isSelected = p.id == selectedPoint?.id;
      final color = isSelected ? '0xD84E55' : '0x1E293B';
      final size = isSelected ? 'mid' : 'small';
      markers.write('&markers=color:$color%7Csize:$size%7Clabel:${p.id.replaceAll("BP", "")}%7C${p.latitude},${p.longitude}');
    }

    final path = StringBuffer('&path=color:0xD84E55EE%7Cweight:4');
    for (final p in points) {
      path.write('%7C${p.latitude},${p.longitude}');
    }

    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$centerLat,$centerLng'
        '&zoom=12'
        '&size=${width}x$height'
        '&scale=2'
        '&maptype=$mapType'
        '$markers'
        '$path'
        '&key=$apiKey';
  }

  static String getLiveTrackingUrl({
    required double busLat,
    required double busLng,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    bool isDeviated = false,
    String mapType = 'roadmap',
    int width = 600,
    int height = 400,
  }) {
    final busMarker = '&markers=color:${isDeviated ? "red" : "0xD84E55"}%7Csize:mid%7Clabel:B%7C$busLat,$busLng';
    final originMarker = '&markers=color:green%7Csize:small%7Clabel:O%7C$originLat,$originLng';
    final destMarker = '&markers=color:blue%7Csize:small%7Clabel:D%7C$destLat,$destLng';

    final scheduledPath = '&path=color:0x3B82F6EE%7Cweight:5%7C$originLat,$originLng%7C12.8342,78.2145%7C12.9234,79.1325%7C$destLat,$destLng';

    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$busLat,$busLng'
        '&zoom=9'
        '&size=${width}x$height'
        '&scale=2'
        '&maptype=$mapType'
        '$originMarker$destMarker$busMarker'
        '$scheduledPath'
        '&key=$apiKey';
  }
}

/// Hybrid Map view: Real Google Maps interface with fallback to pure Dart CustomPaint vector map
class HybridBoardingMapView extends StatefulWidget {
  final List<BoardingPoint> points;
  final BoardingPoint? selectedPoint;
  final String? source;
  final void Function(BoardingPoint point)? onPointSelected;

  const HybridBoardingMapView({
    super.key,
    required this.points,
    required this.selectedPoint,
    this.source,
    this.onPointSelected,
  });

  @override
  State<HybridBoardingMapView> createState() => _HybridBoardingMapViewState();
}

class _HybridBoardingMapViewState extends State<HybridBoardingMapView> {
  bool _useGoogleMaps = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Map Layer: Real interactive Google Map or pure Dart CustomPaint
            Positioned.fill(
              child: _useGoogleMaps
                  ? InteractiveGoogleMapView(
                      mode: 'boarding',
                      apiKey: GoogleMapsConfig.apiKey,
                      origin: widget.source ?? (widget.points.isNotEmpty ? widget.points.first.name : 'Bengaluru'),
                      selectedBpId: widget.selectedPoint?.id,
                      onBoardingPointSelected: (pointId) {
                        if (widget.onPointSelected != null) {
                          try {
                            final matched = widget.points.firstWhere((p) => p.id == pointId);
                            widget.onPointSelected!(matched);
                          } catch (_) {}
                        }
                      },
                    )
                  : CustomPaint(
                      size: const Size(double.infinity, 230),
                      painter: BoardingMapPainter(
                        points: widget.points,
                        selectedPoint: widget.selectedPoint,
                      ),
                    ),
            ),

            // Top Status Badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _useGoogleMaps ? Icons.public : Icons.brush,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _useGoogleMaps ? 'Real Google Maps (Interactive)' : 'Vector Route Map',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Layer Selector (Google Maps vs Vector CustomPaint)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _useGoogleMaps ? Icons.brush : Icons.layers,
                    size: 18,
                    color: const Color(0xFFD84E55),
                  ),
                  tooltip: _useGoogleMaps ? 'Switch to Vector Map' : 'Switch to Real Google Maps',
                  onPressed: () {
                    setState(() {
                      _useGoogleMaps = !_useGoogleMaps;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
