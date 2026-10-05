import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/google_map_view.dart';
import 'dropping_point_screen.dart';

/// Screen 5: Boarding Point Selection with CustomPaint Map view & Landmarks
class BoardingPointScreen extends StatefulWidget {
  final Bus bus;
  final String source;
  final String destination;
  final DateTime journeyDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final List<String> selectedSeats;

  const BoardingPointScreen({
    super.key,
    required this.bus,
    required this.source,
    required this.destination,
    required this.journeyDate,
    this.returnDate,
    required this.isRoundTrip,
    required this.selectedSeats,
  });

  @override
  State<BoardingPointScreen> createState() => _BoardingPointScreenState();
}

class _BoardingPointScreenState extends State<BoardingPointScreen> {
  BoardingPoint? _selectedPoint;

  @override
  void initState() {
    super.initState();
    if (widget.bus.boardingPoints.isNotEmpty) {
      _selectedPoint = widget.bus.boardingPoints.first;
    }
  }

  void _onNext() {
    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a boarding point')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DroppingPointScreen(
          bus: widget.bus,
          source: widget.source,
          destination: widget.destination,
          journeyDate: widget.journeyDate,
          returnDate: widget.returnDate,
          isRoundTrip: widget.isRoundTrip,
          selectedSeats: widget.selectedSeats,
          boardingPoint: _selectedPoint!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Boarding Point'),
      ),
      body: Column(
        children: [
          // Map View with Real Google Maps & CustomPaint
          HybridBoardingMapView(
            points: widget.bus.boardingPoints,
            selectedPoint: _selectedPoint,
            source: widget.source,
            onPointSelected: (point) {
              setState(() {
                _selectedPoint = point;
              });
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Boarding Locations',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // List of Boarding Points
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: widget.bus.boardingPoints.length,
              itemBuilder: (context, index) {
                final point = widget.bus.boardingPoints[index];
                final isSelected = _selectedPoint?.id == point.id;

                return Card(
                  elevation: isSelected ? 2 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFD84E55) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedPoint = point;
                      });
                    },
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? const Color(0xFFD84E55) : Colors.grey.shade200,
                      child: Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            point.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          point.time,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD84E55)),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Landmark: ${point.landmark}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                    trailing: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFFD84E55) : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD84E55),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Next: Dropping Point ->', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
