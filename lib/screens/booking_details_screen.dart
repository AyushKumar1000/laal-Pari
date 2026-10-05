import 'package:flutter/material.dart';
import '../models/models.dart';
import 'ticket_screen.dart';

/// Screen 7: Booking Details (Passenger Info, ID Proof Upload, Concessions, Price Breakdown)
class BookingDetailsScreen extends StatefulWidget {
  final Bus bus;
  final String source;
  final String destination;
  final DateTime journeyDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final List<String> selectedSeats;
  final BoardingPoint boardingPoint;
  final DroppingPoint droppingPoint;

  const BookingDetailsScreen({
    super.key,
    required this.bus,
    required this.source,
    required this.destination,
    required this.journeyDate,
    this.returnDate,
    required this.isRoundTrip,
    required this.selectedSeats,
    required this.boardingPoint,
    required this.droppingPoint,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ayush Kumar');
  final _ageController = TextEditingController(text: '22');
  final _contactController = TextEditingController(text: '9876543210');
  String _gender = 'Male';

  bool _isIdProofUploaded = false;
  String? _idProofFileName;

  bool _hasStudentConcession = false;
  bool _hasRblCard = false;

  void _simulateUploadIdProof() {
    setState(() {
      _isIdProofUploaded = true;
      _idProofFileName = 'student_national_id_card.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID Proof successfully uploaded: student_national_id_card.pdf'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onConfirmBooking() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasStudentConcession && !_isIdProofUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valid ID proof is required to avail Student Concession!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Exact Pricing Calculation
    final seatCount = widget.selectedSeats.length;
    final singleTripBase = widget.bus.basePrice * seatCount;
    final singleTripSurge = widget.bus.isSurgeActive ? (widget.bus.basePrice * 0.20 * seatCount) : 0.0;

    final baseFare = widget.isRoundTrip ? singleTripBase * 2 : singleTripBase;
    final surgeAmount = widget.isRoundTrip ? singleTripSurge * 2 : singleTripSurge;

    // 10% discount on return journey fare
    final roundTripDiscount = widget.isRoundTrip ? (singleTripBase + singleTripSurge) * 0.10 : 0.0;

    final subtotal = (baseFare + surgeAmount) - roundTripDiscount;
    final studentDiscount = _hasStudentConcession ? (subtotal * 0.08) : 0.0;
    final totalPayable = subtotal - studentDiscount;

    // 5% cashback on RBL Bank cards
    final cashbackAmount = _hasRblCard ? (totalPayable * 0.05) : 0.0;

    final passenger = Passenger(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 22,
      gender: _gender,
      contact: _contactController.text.trim(),
      isIdProofUploaded: _isIdProofUploaded,
      idFileName: _idProofFileName,
    );

    final bookingId = 'RB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final bookingRecord = BookingRecord(
      bookingId: bookingId,
      bus: widget.bus,
      source: widget.source,
      destination: widget.destination,
      journeyDate: widget.journeyDate,
      returnDate: widget.returnDate,
      isRoundTrip: widget.isRoundTrip,
      selectedSeats: widget.selectedSeats,
      boardingPoint: widget.boardingPoint,
      droppingPoint: widget.droppingPoint,
      passenger: passenger,
      hasStudentConcession: _hasStudentConcession,
      hasRblCard: _hasRblCard,
      baseFare: baseFare,
      surgeAmount: surgeAmount,
      roundTripDiscount: roundTripDiscount,
      studentDiscount: studentDiscount,
      cashbackAmount: cashbackAmount,
      totalAmount: totalPayable,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketScreen(booking: bookingRecord),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pricing calculation for dynamic UI update
    final seatCount = widget.selectedSeats.length;
    final singleTripBase = widget.bus.basePrice * seatCount;
    final singleTripSurge = widget.bus.isSurgeActive ? (widget.bus.basePrice * 0.20 * seatCount) : 0.0;

    final baseFare = widget.isRoundTrip ? singleTripBase * 2 : singleTripBase;
    final surgeAmount = widget.isRoundTrip ? singleTripSurge * 2 : singleTripSurge;
    final roundTripDiscount = widget.isRoundTrip ? (singleTripBase + singleTripSurge) * 0.10 : 0.0;

    final subtotal = (baseFare + surgeAmount) - roundTripDiscount;
    final studentDiscount = _hasStudentConcession ? (subtotal * 0.08) : 0.0;
    final totalPayable = subtotal - studentDiscount;
    final cashbackAmount = _hasRblCard ? (totalPayable * 0.05) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking & Passenger Details'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Trip summary capsule
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.source} ➔ ${widget.destination}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${widget.selectedSeats.length} Seats (${widget.selectedSeats.join(', ')})', style: const TextStyle(color: Color(0xFFD84E55), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Passenger Details Form Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Primary Passenger Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter passenger name' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Valid age' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _gender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                                DropdownMenuItem(value: 'Female', child: Text('Female')),
                                DropdownMenuItem(value: 'Other', child: Text('Other')),
                              ],
                              onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Mobile Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid 10-digit number' : null,
                      ),
                      const SizedBox(height: 16),

                      // ID Proof Simulation
                      const Text('ID Verification (Govt / Student ID)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: _simulateUploadIdProof,
                        icon: Icon(
                          _isIdProofUploaded ? Icons.check_circle : Icons.upload_file,
                          color: _isIdProofUploaded ? Colors.green : const Color(0xFFD84E55),
                        ),
                        label: Text(
                          _isIdProofUploaded
                              ? 'ID Proof Uploaded: $_idProofFileName'
                              : 'Upload ID Proof (Simulated)',
                          style: TextStyle(
                            color: _isIdProofUploaded ? Colors.green.shade800 : const Color(0xFFD84E55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Offers & Concessions Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offers & Concessions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Student Concession (8% OFF)', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Valid student ID required upon travel', style: TextStyle(fontSize: 12)),
                        value: _hasStudentConcession,
                        onChanged: (val) {
                          if (val && !_isIdProofUploaded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please upload ID proof to activate student concession.')),
                            );
                          }
                          setState(() {
                            _hasStudentConcession = val;
                          });
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('RBL Bank Card Partner Offer', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Get 5% instant cashback on booking', style: TextStyle(fontSize: 12, color: Colors.indigo)),
                        value: _hasRblCard,
                        onChanged: (val) {
                          setState(() {
                            _hasRblCard = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Final Price Breakdown Card
              Card(
                elevation: 2,
                color: const Color(0xFFFAFAFA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fare Breakdown',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _priceRow('Base Fare (${widget.selectedSeats.length} seats ${widget.isRoundTrip ? "x 2 legs" : ""})', '₹${baseFare.toStringAsFixed(0)}'),
                      if (surgeAmount > 0)
                        _priceRow('Dynamic Surge (High Demand +20%)', '+₹${surgeAmount.toStringAsFixed(0)}', textColor: Colors.orange.shade900),
                      if (roundTripDiscount > 0)
                        _priceRow('Round Trip Discount (10% on return)', '-₹${roundTripDiscount.toStringAsFixed(0)}', textColor: Colors.green),
                      if (studentDiscount > 0)
                        _priceRow('Student Concession (8% OFF)', '-₹${studentDiscount.toStringAsFixed(0)}', textColor: Colors.green),
                      const Divider(thickness: 1.2),
                      _priceRow(
                        'Total Payable',
                        '₹${totalPayable.toStringAsFixed(0)}',
                        isBold: true,
                        fontSize: 17,
                        textColor: const Color(0xFFD84E55),
                      ),
                      if (_hasRblCard) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'RBL Partner Cashback: ₹${cashbackAmount.toStringAsFixed(0)} (5%)',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pay & Book Button
              ElevatedButton(
                onPressed: _onConfirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD84E55),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Pay ₹${totalPayable.toStringAsFixed(0)} & Generate Ticket',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String amount, {bool isBold = false, double fontSize = 14, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: fontSize,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
