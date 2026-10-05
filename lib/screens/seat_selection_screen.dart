import 'package:flutter/material.dart';
import '../models/models.dart';
import 'boarding_point_screen.dart';

/// Screen 4: Seat Selection (Sleeper Lower/Upper decks or Seater grid)
class SeatSelectionScreen extends StatefulWidget {
  final Bus bus;
  final String source;
  final String destination;
  final DateTime journeyDate;
  final DateTime? returnDate;
  final bool isRoundTrip;

  const SeatSelectionScreen({
    super.key,
    required this.bus,
    required this.source,
    required this.destination,
    required this.journeyDate,
    this.returnDate,
    required this.isRoundTrip,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> with SingleTickerProviderStateMixin {
  final Set<String> _selectedSeats = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSeat(Seat seat) {
    if (seat.isBooked) return;
    setState(() {
      if (_selectedSeats.contains(seat.number)) {
        _selectedSeats.remove(seat.number);
      } else {
        _selectedSeats.add(seat.number);
      }
    });
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(Colors.white, Colors.grey.shade400, 'Available'),
          _legendItem(const Color(0xFFD84E55), const Color(0xFFD84E55), 'Selected', textColor: Colors.white),
          _legendItem(Colors.grey.shade400, Colors.grey.shade400, 'Booked'),
        ],
      ),
    );
  }

  Widget _legendItem(Color bg, Color border, String label, {Color textColor = Colors.black}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSleeperBerth(Seat seat) {
    final isSelected = _selectedSeats.contains(seat.number);
    final isBooked = seat.isBooked;

    Color bg;
    Color border;
    Color textCol;

    if (isBooked) {
      bg = Colors.grey.shade300;
      border = Colors.grey.shade400;
      textCol = Colors.grey.shade600;
    } else if (isSelected) {
      bg = const Color(0xFFD84E55);
      border = const Color(0xFFD84E55);
      textCol = Colors.white;
    } else {
      bg = Colors.white;
      border = Colors.grey.shade400;
      textCol = Colors.black87;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seat),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFD84E55).withValues(alpha: 0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bed, size: 20, color: textCol),
            const SizedBox(height: 2),
            Text(
              seat.number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeaterSeat(Seat seat) {
    final isSelected = _selectedSeats.contains(seat.number);
    final isBooked = seat.isBooked;

    Color bg;
    Color border;
    Color textCol;

    if (isBooked) {
      bg = Colors.grey.shade300;
      border = Colors.grey.shade400;
      textCol = Colors.grey.shade600;
    } else if (isSelected) {
      bg = const Color(0xFFD84E55);
      border = const Color(0xFFD84E55);
      textCol = Colors.white;
    } else {
      bg = Colors.white;
      border = Colors.grey.shade400;
      textCol = Colors.black87;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seat),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chair, size: 18, color: textCol),
            Text(
              seat.number,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleeperLayout() {
    final lowerSeats = widget.bus.seats.where((s) => !s.isUpperDeck).toList();
    final upperSeats = widget.bus.seats.where((s) => s.isUpperDeck).toList();

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD84E55),
          indicatorColor: const Color(0xFFD84E55),
          tabs: const [
            Tab(text: 'Lower Deck (Berths)'),
            Tab(text: 'Upper Deck (Berths)'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Lower Deck Grid (2 berths left, aisle, 1 berth right)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: lowerSeats.length,
                  itemBuilder: (context, i) => _buildSleeperBerth(lowerSeats[i]),
                ),
              ),
              // Upper Deck Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: upperSeats.length,
                  itemBuilder: (context, i) => _buildSleeperBerth(upperSeats[i]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeaterLayout() {
    final seats = widget.bus.seats;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Driver Cabin', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
              Icon(Icons.directions_bus, color: Colors.grey.shade600),
            ],
          ),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 2x2 with natural aisle
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: seats.length,
              itemBuilder: (context, i) => _buildSeaterSeat(seats[i]),
            ),
          ),
        ],
      ),
    );
  }

  void _onProceed() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 seat to proceed')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoardingPointScreen(
          bus: widget.bus,
          source: widget.source,
          destination: widget.destination,
          journeyDate: widget.journeyDate,
          returnDate: widget.returnDate,
          isRoundTrip: widget.isRoundTrip,
          selectedSeats: _selectedSeats.toList()..sort(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSleeper = widget.bus.busType == BusType.acSleeper || (widget.bus.busType == BusType.volvo && widget.bus.seats.any((s) => s.isSleeper));
    final seatPrice = widget.bus.effectiveSeatPrice;
    final totalEstimate = seatPrice * _selectedSeats.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Seats (${widget.bus.operatorName})'),
      ),
      body: Column(
        children: [
          // Dynamic Surge banner if applicable
          if (widget.bus.isSurgeActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.orange.shade900, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'High Demand: Only ${widget.bus.seatsLeft} seats left! 20% dynamic surge applied.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          _buildLegend(),

          Expanded(
            child: isSleeper ? _buildSleeperLayout() : _buildSeaterLayout(),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Seats: ${_selectedSeats.isEmpty ? 'None' : _selectedSeats.join(', ')}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '₹${totalEstimate.toStringAsFixed(0)} (Base)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD84E55)),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD84E55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Boarding Point ->', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
