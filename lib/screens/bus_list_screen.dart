import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import 'operator_details_screen.dart';
import 'seat_selection_screen.dart';

/// Screen 2: Bus List with dynamic cards & comprehensive Filter Panel
class BusListScreen extends StatefulWidget {
  final String source;
  final String destination;
  final DateTime journeyDate;
  final DateTime? returnDate;
  final bool isRoundTrip;

  const BusListScreen({
    super.key,
    required this.source,
    required this.destination,
    required this.journeyDate,
    this.returnDate,
    required this.isRoundTrip,
  });

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  // Filter States
  final Set<BusType> _selectedBusTypes = {};
  final Set<DepartureTimeSlot> _selectedTimeSlots = {};
  final Set<Amenity> _selectedAmenities = {};
  RangeValues _priceRange = const RangeValues(300, 1500);

  List<Bus> get _filteredBuses {
    return MockData.getBusesForRoute(widget.source, widget.destination).where((bus) {
      // 1. Bus Type Filter
      if (_selectedBusTypes.isNotEmpty && !_selectedBusTypes.contains(bus.busType)) {
        return false;
      }

      // 2. Price Range Filter
      if (bus.basePrice < _priceRange.start || bus.basePrice > _priceRange.end) {
        return false;
      }

      // 3. Amenities Filter
      if (_selectedAmenities.isNotEmpty) {
        for (var am in _selectedAmenities) {
          if (!bus.amenities.contains(am)) return false;
        }
      }

      // 4. Departure Time Slot Filter
      if (_selectedTimeSlots.isNotEmpty) {
        bool inAnySlot = false;
        for (var slot in _selectedTimeSlots) {
          if (slot == DepartureTimeSlot.night) {
            if (bus.departureHour >= 21 || bus.departureHour < 6) {
              inAnySlot = true;
              break;
            }
          } else {
            if (bus.departureHour >= slot.startHour && bus.departureHour < slot.endHour) {
              inAnySlot = true;
              break;
            }
          }
        }
        if (!inAnySlot) return false;
      }

      return true;
    }).toList();
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedBusTypes.clear();
                            _selectedTimeSlots.clear();
                            _selectedAmenities.clear();
                            _priceRange = const RangeValues(300, 1500);
                          });
                          setState(() {});
                        },
                        child: const Text('Reset All', style: TextStyle(color: Color(0xFFD84E55))),
                      ),
                    ],
                  ),
                  const Divider(),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Bus Types
                          const Text('Bus Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: BusType.values.map((type) {
                              final isSelected = _selectedBusTypes.contains(type);
                              return FilterChip(
                                label: Text(type.label),
                                selected: isSelected,
                                selectedColor: const Color(0xFFD84E55).withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFFD84E55),
                                onSelected: (sel) {
                                  setModalState(() {
                                    if (sel) {
                                      _selectedBusTypes.add(type);
                                    } else {
                                      _selectedBusTypes.remove(type);
                                    }
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          // 2. Departure Time Slots
                          const Text('Departure Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: DepartureTimeSlot.values.map((slot) {
                              final isSelected = _selectedTimeSlots.contains(slot);
                              return FilterChip(
                                label: Text(slot.label),
                                selected: isSelected,
                                selectedColor: const Color(0xFFD84E55).withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFFD84E55),
                                onSelected: (sel) {
                                  setModalState(() {
                                    if (sel) {
                                      _selectedTimeSlots.add(slot);
                                    } else {
                                      _selectedTimeSlots.remove(slot);
                                    }
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          // 3. Price Range Slider
                          Text(
                            'Price Range (₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          RangeSlider(
                            values: _priceRange,
                            min: 300,
                            max: 1500,
                            divisions: 24,
                            activeColor: const Color(0xFFD84E55),
                            labels: RangeLabels('₹${_priceRange.start.toInt()}', '₹${_priceRange.end.toInt()}'),
                            onChanged: (values) {
                              setModalState(() {
                                _priceRange = values;
                              });
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 18),

                          // 4. Amenities
                          const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Amenity.values.map((amenity) {
                              final isSelected = _selectedAmenities.contains(amenity);
                              return FilterChip(
                                avatar: Icon(amenity.icon, size: 16),
                                label: Text(amenity.label),
                                selected: isSelected,
                                selectedColor: const Color(0xFFD84E55).withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFFD84E55),
                                onSelected: (sel) {
                                  setModalState(() {
                                    if (sel) {
                                      _selectedAmenities.add(amenity);
                                    } else {
                                      _selectedAmenities.remove(amenity);
                                    }
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Apply Filter Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84E55),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Apply Filters (${_filteredBuses.length} Buses)'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final buses = _filteredBuses;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.source} ➔ ${widget.destination}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${_formatDate(widget.journeyDate)} • ${buses.length} Buses', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Buses',
            onPressed: _openFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter overview bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${buses.length} available buses',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                OutlinedButton.icon(
                  onPressed: _openFilterModal,
                  icon: const Icon(Icons.tune, size: 16, color: Color(0xFFD84E55)),
                  label: const Text('Filter Panel', style: TextStyle(color: Color(0xFFD84E55), fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD84E55)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
              ],
            ),
          ),

          // Bus Cards List
          Expanded(
            child: buses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus_filled_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No buses matching your filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedBusTypes.clear();
                              _selectedTimeSlots.clear();
                              _selectedAmenities.clear();
                              _priceRange = const RangeValues(300, 1500);
                            });
                          },
                          child: const Text('Reset All Filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      final bus = buses[index];
                      return _buildBusCard(bus);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(Bus bus) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeatSelectionScreen(
                bus: bus,
                source: widget.source,
                destination: widget.destination,
                journeyDate: widget.journeyDate,
                returnDate: widget.returnDate,
                isRoundTrip: widget.isRoundTrip,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Operator Name and Dynamic Pricing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.operatorName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          bus.busType.label,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${bus.effectiveSeatPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD84E55)),
                      ),
                      if (bus.isSurgeActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+20% Surge',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 18),

              // Departure, Duration, Arrival
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bus.departureTime,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(width: 20, height: 1, color: Colors.grey),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          bus.duration,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ),
                      Container(width: 20, height: 1, color: Colors.grey),
                    ],
                  ),
                  Text(
                    bus.arrivalTime,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom Row: Rating (Tappable for Screen 3), Seats left, Amenities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rating Tap Target
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OperatorDetailsScreen(bus: bus),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${bus.rating} (${bus.reviewCount})',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.info_outline, size: 12, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),

                  // Amenity icons
                  Row(
                    children: bus.amenities
                        .take(3)
                        .map((am) => Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Icon(am.icon, size: 16, color: Colors.grey.shade700),
                            ))
                        .toList(),
                  ),

                  // Seats left
                  Text(
                    '${bus.seatsLeft} seats left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: bus.seatsLeft <= 5 ? Colors.red.shade700 : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
