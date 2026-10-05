import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/custom_map_paint.dart';
import '../widgets/google_map_view.dart';
import '../widgets/interactive_google_map.dart';

/// Screen 10: Full-Screen Live Bus Tracking with Vector & Google Maps
class LiveTrackingScreen extends StatefulWidget {
  final Bus bus;
  final BookingRecord booking;

  const LiveTrackingScreen({
    super.key,
    required this.bus,
    required this.booking,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  Timer? _timer;
  double _progress = 0.22; // 0.0 to 1.0 along the route
  int _speed = 68; // km/h
  bool _isDeviated = false;
  int _etaMinutes = 32;
  String _currentNextStop = 'Food Plaza Highway Oasis';
  bool _useGoogleMaps = true; // Default to real interactive Google Maps
  bool _isSheetExpanded = true;

  @override
  void initState() {
    super.initState();
    if (widget.bus.restStops.isNotEmpty) {
      _currentNextStop = widget.bus.restStops.first.name;
    }

    // Timer driving live bus movement along the highway
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        if (!_isDeviated) {
          _progress += 0.012;
          if (_progress > 0.96) {
            _progress = 0.04;
          }

          _speed = 65 + Random().nextInt(12);
          _etaMinutes = max(2, (45 * (1.0 - _progress)).toInt());

          if (_progress > 0.5 && widget.bus.restStops.length > 1) {
            _currentNextStop = widget.bus.restStops[1].name;
          } else if (widget.bus.restStops.isNotEmpty) {
            _currentNextStop = widget.bus.restStops.first.name;
          }
        } else {
          _speed = 32 + Random().nextInt(6);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRouteDeviation() {
    setState(() {
      _isDeviated = !_isDeviated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDeviated
              ? 'SIMULATION: Route deviation detected! Warning banner triggered.'
              : 'SIMULATION: Bus returned to scheduled highway corridor.',
        ),
        backgroundColor: _isDeviated ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.booking.source} ➔ ${widget.booking.destination} (Live GPS)'),
        actions: [
          IconButton(
            tooltip: 'Toggle Google Maps / Vector Map',
            icon: Icon(_useGoogleMaps ? Icons.layers : Icons.brush),
            onPressed: () {
              setState(() {
                _useGoogleMaps = !_useGoogleMaps;
              });
            },
          ),
          IconButton(
            tooltip: 'Simulate Route Deviation',
            icon: Icon(
              _isDeviated ? Icons.warning : Icons.alt_route,
              color: _isDeviated ? Colors.amberAccent : Colors.white,
            ),
            onPressed: _toggleRouteDeviation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Full-Screen Interactive Map Canvas (100% of viewport)
          Positioned.fill(
            child: _useGoogleMaps
                ? InteractiveGoogleMapView(
                    mode: 'tracking',
                    apiKey: GoogleMapsConfig.apiKey,
                    origin: widget.booking.source,
                    destination: widget.booking.destination,
                    progress: _progress,
                    isDeviated: _isDeviated,
                  )
                : InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.0,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: LiveTrackingMapPainter(
                        progress: _progress,
                        isDeviated: _isDeviated,
                        origin: widget.booking.source,
                        destination: widget.booking.destination,
                        nextStop: _currentNextStop,
                      ),
                    ),
                  ),
          ),

          // 2. Route Deviation Banner
          if (_isDeviated)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.red.shade700,
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ROUTE DEVIATION ALERT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Bus has departed from scheduled highway corridor! Control room notified.',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Floating Speedometer & GPS Telemetry HUD (Top-Right)
          Positioned(
            top: _isDeviated ? 60 : 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('LIVE SPEED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_speed',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _isDeviated ? Colors.red : const Color(0xFFD84E55),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text('km/h', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${((1.0 - _progress) * 340).toInt()} km left',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating Live Status Pill (Top-Left)
          Positioned(
            top: _isDeviated ? 60 : 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _isDeviated ? Colors.red.shade900 : Colors.green.shade800,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isDeviated ? 'OFF ROUTE' : 'LIVE GPS TRACKING',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 5. Floating / Collapsible Bottom Telemetry Sheet
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sheet Header & Collapse Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFD84E55).withValues(alpha: 0.1),
                                  child: const Icon(Icons.directions_bus, color: Color(0xFFD84E55), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.bus.operatorName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        widget.bus.busType.label,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(_isSheetExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                            onPressed: () {
                              setState(() {
                                _isSheetExpanded = !_isSheetExpanded;
                              });
                            },
                          ),
                        ],
                      ),

                      if (_isSheetExpanded) ...[
                        const Divider(height: 14),
                        // Next Stop Info
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFFD84E55), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Next Upcoming Stop', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    _currentNextStop,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ETA: $_etaMinutes mins',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Driver Info & Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Color(0xFF1E293B),
                                    child: Icon(Icons.person, color: Colors.white, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.bus.driver.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '⭐ ${widget.bus.driver.rating} • ${widget.bus.driver.contact}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone, color: Colors.green, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling Driver ${widget.bus.driver.name} at ${widget.bus.driver.contact}...')),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: _toggleRouteDeviation,
                                  icon: Icon(_isDeviated ? Icons.check_circle : Icons.warning_amber, size: 13, color: _isDeviated ? Colors.green : Colors.red),
                                  label: Text(
                                    _isDeviated ? 'Restore' : 'Deviate',
                                    style: TextStyle(fontSize: 11, color: _isDeviated ? Colors.green : Colors.red),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    side: BorderSide(color: _isDeviated ? Colors.green : Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
