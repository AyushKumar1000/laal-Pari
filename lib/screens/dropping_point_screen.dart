import 'package:flutter/material.dart';
import '../models/models.dart';
import 'booking_details_screen.dart';

/// Screen 6: Dropping Point Selection with landmark details and ETA list
class DroppingPointScreen extends StatefulWidget {
  final Bus bus;
  final String source;
  final String destination;
  final DateTime journeyDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final List<String> selectedSeats;
  final BoardingPoint boardingPoint;

  const DroppingPointScreen({
    super.key,
    required this.bus,
    required this.source,
    required this.destination,
    required this.journeyDate,
    this.returnDate,
    required this.isRoundTrip,
    required this.selectedSeats,
    required this.boardingPoint,
  });

  @override
  State<DroppingPointScreen> createState() => _DroppingPointScreenState();
}

class _DroppingPointScreenState extends State<DroppingPointScreen> {
  DroppingPoint? _selectedDroppingPoint;

  @override
  void initState() {
    super.initState();
    if (widget.bus.droppingPoints.isNotEmpty) {
      _selectedDroppingPoint = widget.bus.droppingPoints.first;
    }
  }

  void _onNext() {
    if (_selectedDroppingPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a dropping point')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(
          bus: widget.bus,
          source: widget.source,
          destination: widget.destination,
          journeyDate: widget.journeyDate,
          returnDate: widget.returnDate,
          isRoundTrip: widget.isRoundTrip,
          selectedSeats: widget.selectedSeats,
          boardingPoint: widget.boardingPoint,
          droppingPoint: _selectedDroppingPoint!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Dropping Point'),
      ),
      body: Column(
        children: [
          // Summary Header Card
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.pin_drop, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Boarding: ${widget.boardingPoint.name} (${widget.boardingPoint.time})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        'Seats: ${widget.selectedSeats.join(', ')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Dropping Locations & ETA',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Dropping points list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.bus.droppingPoints.length,
              itemBuilder: (context, index) {
                final drop = widget.bus.droppingPoints[index];
                final isSelected = _selectedDroppingPoint?.id == drop.id;

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
                        _selectedDroppingPoint = drop;
                      });
                    },
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? const Color(0xFFD84E55) : Colors.grey.shade200,
                      child: Icon(
                        Icons.flag,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            drop.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ETA: ${drop.eta}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Landmark: ${drop.landmark}',
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

          // Bottom Button
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
                child: const Text('Next: Passenger Details ->', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
