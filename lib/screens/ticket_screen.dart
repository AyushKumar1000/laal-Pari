import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/custom_map_paint.dart';
import 'cancellation_reschedule_screen.dart';
import 'live_tracking_screen.dart';

/// Screen 8: Ticket Screen with CustomPaint QR Code, Full Summary & Cancellation Policy
class TicketScreen extends StatefulWidget {
  final BookingRecord booking;

  const TicketScreen({super.key, required this.booking});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Ticket Confirmation'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status banner if cancelled or rescheduled
            if (b.isCancelled)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'TICKET CANCELLED - Refund Initiated',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else if (b.rescheduledDate != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade800),
                ),
                child: Row(
                  children: [
                    Icon(Icons.update, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'RESCHEDULED TO: ${_formatDate(b.rescheduledDate!)} (${b.rescheduledTimeSlot})',
                        style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Ticket Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Operator & Booking ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.bus.operatorName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              b.bus.busType.label,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD84E55).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${b.bookingId}',
                            style: const TextStyle(
                              color: Color(0xFFD84E55),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // CustomPaint QR Code
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomPaint(
                        size: const Size(140, 140),
                        painter: QrCodePainter(data: '${b.bookingId}|${b.passenger.name}|${b.selectedSeats.join(",")}'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Scan QR during bus boarding', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const Divider(height: 24),

                    // Journey Route & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoCol('From', b.source),
                        const Icon(Icons.arrow_forward, color: Color(0xFFD84E55)),
                        _infoCol('To', b.destination),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoCol('Journey Date', _formatDate(b.journeyDate)),
                        if (b.isRoundTrip && b.returnDate != null)
                          _infoCol('Return Date', _formatDate(b.returnDate!)),
                        _infoCol('Seats', b.selectedSeats.join(', ')),
                      ],
                    ),
                    const Divider(height: 24),

                    // Boarding & Dropping Points
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Boarding Point (${b.boardingPoint.time})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            '${b.boardingPoint.name} - ${b.boardingPoint.landmark}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text('Dropping Point (ETA ${b.droppingPoint.eta})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            '${b.droppingPoint.name} - ${b.droppingPoint.landmark}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),

                    // Passenger Details
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Passenger Information', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '${b.passenger.name} (${b.passenger.age}y, ${b.passenger.gender}) • ${b.passenger.contact}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),

                    // Price Breakdown
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fare Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          _priceRow('Base Fare', '₹${b.baseFare.toStringAsFixed(0)}'),
                          if (b.surgeAmount > 0)
                            _priceRow('Dynamic Surge (+20%)', '+₹${b.surgeAmount.toStringAsFixed(0)}', textColor: Colors.orange.shade900),
                          if (b.roundTripDiscount > 0)
                            _priceRow('Round Trip Discount (10%)', '-₹${b.roundTripDiscount.toStringAsFixed(0)}', textColor: Colors.green),
                          if (b.studentDiscount > 0)
                            _priceRow('Student Concession (8%)', '-₹${b.studentDiscount.toStringAsFixed(0)}', textColor: Colors.green),
                          const Divider(),
                          _priceRow('Total Paid', '₹${b.totalAmount.toStringAsFixed(0)}', isBold: true, fontSize: 16, textColor: const Color(0xFFD84E55)),
                          if (b.cashbackAmount > 0)
                            _priceRow('RBL Card Cashback Credited', '₹${b.cashbackAmount.toStringAsFixed(0)}', textColor: Colors.indigo, isBold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancellation Policy Box
            Card(
              elevation: 1,
              color: const Color(0xFFFFFBEB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.amber.shade300),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.policy, color: Colors.amber, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Cancellation Policy',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• More than 24 hours before departure: 90% refund', style: TextStyle(fontSize: 12)),
                    Text('• 12 to 24 hours before departure: 75% refund', style: TextStyle(fontSize: 12)),
                    Text('• 6 to 12 hours before departure: 50% refund', style: TextStyle(fontSize: 12)),
                    Text('• Less than 6 hours before departure: No refund (0%)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                // Live Tracking Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiveTrackingScreen(bus: b.bus, booking: b),
                        ),
                      );
                    },
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('Live Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Cancel / Reschedule Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push<BookingRecord>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CancellationRescheduleScreen(booking: b),
                        ),
                      );
                      if (updated != null) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Cancel / Reschedule'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD84E55),
                      side: const BorderSide(color: Color(0xFFD84E55)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCol(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _priceRow(String label, String amount, {bool isBold = false, double fontSize = 13, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: fontSize)),
          Text(amount, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: fontSize, color: textColor ?? Colors.black87)),
        ],
      ),
    );
  }
}
