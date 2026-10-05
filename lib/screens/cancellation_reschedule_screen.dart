import 'package:flutter/material.dart';
import '../models/models.dart';

/// Screen 9: Cancellation and Rescheduling with Instant Refund Calculator
class CancellationRescheduleScreen extends StatefulWidget {
  final BookingRecord booking;

  const CancellationRescheduleScreen({super.key, required this.booking});

  @override
  State<CancellationRescheduleScreen> createState() => _CancellationRescheduleScreenState();
}

class _CancellationRescheduleScreenState extends State<CancellationRescheduleScreen> {
  // Cancellation Calculator state
  double _hoursBeforeDeparture = 28.0; // Default: >24h

  // Reschedule state
  late DateTime _newDate;
  String _selectedTimeSlot = 'Morning (6 AM - 12 PM)';

  final List<String> _timeSlots = [
    'Morning (6 AM - 12 PM)',
    'Afternoon (12 PM - 5 PM)',
    'Evening (5 PM - 9 PM)',
    'Night (9 PM - 6 AM)',
  ];

  @override
  void initState() {
    super.initState();
    _newDate = widget.booking.journeyDate.add(const Duration(days: 1));
  }

  // Refund calculation logic
  double get _refundPercentage {
    if (_hoursBeforeDeparture > 24.0) {
      return 0.90;
    } else if (_hoursBeforeDeparture >= 12.0) {
      return 0.75;
    } else if (_hoursBeforeDeparture >= 6.0) {
      return 0.50;
    } else {
      return 0.0;
    }
  }

  double get _refundAmount => widget.booking.totalAmount * _refundPercentage;
  double get _cancellationFee => widget.booking.totalAmount - _refundAmount;

  void _onCancelTicket() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Ticket Cancellation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paid Fare: ₹${widget.booking.totalAmount.toStringAsFixed(0)}'),
            Text('Time Left: ${_hoursBeforeDeparture.toStringAsFixed(1)} hours'),
            Text('Refund Rate: ${(_refundPercentage * 100).toInt()}%'),
            const SizedBox(height: 8),
            Text(
              'Refund Payable: ₹${_refundAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Amount will be credited to original payment source within 24-48 hours.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.booking.isCancelled = true;
              Navigator.pop(ctx); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket Cancelled! Refund of ₹${_refundAmount.toStringAsFixed(0)} initiated.'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context, widget.booking); // Return to ticket
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _onReschedule() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _newDate = picked;
      });
    }
  }

  void _onConfirmReschedule() {
    setState(() {
      widget.booking.rescheduledDate = _newDate;
      widget.booking.rescheduledTimeSlot = _selectedTimeSlot;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Journey rescheduled to ${_formatDate(_newDate)} ($_selectedTimeSlot) successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, widget.booking);
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancellation & Rescheduling'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ticket Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.bus.operatorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${b.source} ➔ ${b.destination}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      ],
                    ),
                    Text(
                      'Paid: ₹${b.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD84E55)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Instant Cancellation Calculator
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calculate, color: Color(0xFFD84E55)),
                        SizedBox(width: 8),
                        Text(
                          'Cancellation Calculator',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Slide to test time remaining before scheduled departure:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // Slider for hours before departure
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Time Left:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD84E55).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_hoursBeforeDeparture.toStringAsFixed(0)} Hours',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD84E55)),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _hoursBeforeDeparture,
                      min: 0,
                      max: 48,
                      divisions: 48,
                      label: '${_hoursBeforeDeparture.toInt()}h',
                      activeColor: const Color(0xFFD84E55),
                      onChanged: (val) {
                        setState(() {
                          _hoursBeforeDeparture = val;
                        });
                      },
                    ),

                    // Quick test presets
                    Wrap(
                      spacing: 8,
                      children: [
                        _presetChip(30, '>24h (90%)'),
                        _presetChip(18, '12-24h (75%)'),
                        _presetChip(8, '6-12h (50%)'),
                        _presetChip(3, '<6h (0%)'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Live refund breakdown container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _refundPercentage > 0 ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _refundPercentage > 0 ? Colors.green.shade200 : Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Refund Percentage Eligible:'),
                              Text(
                                '${(_refundPercentage * 100).toInt()}%',
                                style: TextStyle(fontWeight: FontWeight.bold, color: _refundPercentage > 0 ? Colors.green.shade800 : Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Deduction / Cancellation Fee:'),
                              Text('₹${_cancellationFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Instant Refund Payable:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(
                                '₹${_refundAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: _refundPercentage > 0 ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: b.isCancelled ? null : _onCancelTicket,
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(b.isCancelled ? 'Ticket Already Cancelled' : 'Cancel Ticket Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Rescheduling Option
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.event_repeat, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          'Reschedule Journey',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Pick a new journey date & convenient time slot:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),

                    // New Date Picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month, color: Colors.indigo),
                      title: const Text('New Journey Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        _formatDate(_newDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      trailing: TextButton(
                        onPressed: b.isCancelled ? null : _onReschedule,
                        child: const Text('Pick Date'),
                      ),
                    ),
                    const Divider(),

                    // Time slot dropdown
                    const Text('Preferred Time Slot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTimeSlot,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: _timeSlots.map((slot) => DropdownMenuItem(value: slot, child: Text(slot))).toList(),
                      onChanged: b.isCancelled ? null : (v) => setState(() => _selectedTimeSlot = v ?? _selectedTimeSlot),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Reschedule Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: b.isCancelled ? null : _onConfirmReschedule,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirm Rescheduling'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(double hours, String label) {
    final isSelected = (_hoursBeforeDeparture - hours).abs() < 1.0;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: const Color(0xFFD84E55),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _hoursBeforeDeparture = hours;
          });
        }
      },
    );
  }
}
