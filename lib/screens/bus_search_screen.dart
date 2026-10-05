import 'package:flutter/material.dart';
import 'bus_list_screen.dart';

/// Screen 1: Bus Search
class BusSearchScreen extends StatefulWidget {
  const BusSearchScreen({super.key});

  @override
  State<BusSearchScreen> createState() => _BusSearchScreenState();
}

class _BusSearchScreenState extends State<BusSearchScreen> {
  final _sourceController = TextEditingController(text: 'Bengaluru');
  final _destinationController = TextEditingController(text: 'Chennai');

  DateTime _journeyDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _returnDate;
  bool _isRoundTrip = false;

  void _selectDate({required bool isReturn}) async {
    final initialDate = isReturn
        ? (_returnDate ?? _journeyDate.add(const Duration(days: 2)))
        : _journeyDate;
    final firstDate = isReturn ? _journeyDate : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        if (isReturn) {
          _returnDate = picked;
        } else {
          _journeyDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(_journeyDate)) {
            _returnDate = _journeyDate.add(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final temp = _sourceController.text;
      _sourceController.text = _destinationController.text;
      _destinationController.text = temp;
    });
  }

  void _onSearch() {
    if (_sourceController.text.trim().isEmpty || _destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both source and destination')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusListScreen(
          source: _sourceController.text.trim(),
          destination: _destinationController.text.trim(),
          journeyDate: _journeyDate,
          returnDate: _isRoundTrip ? _returnDate : null,
          isRoundTrip: _isRoundTrip,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laal Pari - Intercity Bus Booking'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Source field
                    TextField(
                      controller: _sourceController,
                      decoration: const InputDecoration(
                        labelText: 'Source City / From',
                        prefixIcon: Icon(Icons.trip_origin, color: Color(0xFFD84E55)),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Swap Button
                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: Color(0xFFD84E55), size: 28),
                      onPressed: _swapLocations,
                    ),
                    const SizedBox(height: 10),

                    // Destination field
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination City / To',
                        prefixIcon: Icon(Icons.location_on, color: Color(0xFFD84E55)),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date picker card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Journey Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: Color(0xFFD84E55)),
                      title: const Text('Journey Date', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      subtitle: Text(
                        _formatDate(_journeyDate),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectDate(isReturn: false),
                        child: const Text('Change'),
                      ),
                    ),

                    const Divider(),

                    // Round trip toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Book Return Journey', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Get 10% discount on return fare', style: TextStyle(fontSize: 12, color: Colors.green)),
                      value: _isRoundTrip,
                      onChanged: (val) {
                        setState(() {
                          _isRoundTrip = val;
                          if (_isRoundTrip && _returnDate == null) {
                            _returnDate = _journeyDate.add(const Duration(days: 2));
                          }
                        });
                      },
                    ),

                    if (_isRoundTrip) ...[
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_repeat, color: Colors.indigo),
                        title: const Text('Return Date', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: Text(
                          _returnDate != null ? _formatDate(_returnDate!) : 'Select Return Date',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        trailing: TextButton(
                          onPressed: () => _selectDate(isReturn: true),
                          child: const Text('Select'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search Buses Button
            ElevatedButton(
              onPressed: _onSearch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFD84E55),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 22),
                  SizedBox(width: 8),
                  Text('Search Buses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
