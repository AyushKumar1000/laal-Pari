import 'package:flutter/material.dart';

enum BusType {
  acSleeper('AC Sleeper'),
  volvo('Volvo'),
  ordinary('Ordinary'),
  seater('Seater');

  final String label;
  const BusType(this.label);
}

enum Amenity {
  chargingPoint('Charging Point', Icons.power),
  blanket('Blanket', Icons.bed),
  waterBottle('Water Bottle', Icons.local_drink),
  tv('TV / Entertainment', Icons.tv);

  final String label;
  final IconData icon;
  const Amenity(this.label, this.icon);
}

enum DepartureTimeSlot {
  morning('Morning (6 AM - 12 PM)', 6, 12),
  afternoon('Afternoon (12 PM - 5 PM)', 12, 17),
  evening('Evening (5 PM - 9 PM)', 17, 21),
  night('Night (9 PM - 6 AM)', 21, 6);

  final String label;
  final int startHour;
  final int endHour;
  const DepartureTimeSlot(this.label, this.startHour, this.endHour);
}

class RestStop {
  final String name;
  final String eta;
  final String duration;

  const RestStop({
    required this.name,
    required this.eta,
    required this.duration,
  });
}

class BoardingPoint {
  final String id;
  final String name;
  final String landmark;
  final String time;
  final double mapX; // normalized 0.0 - 1.0
  final double mapY; // normalized 0.0 - 1.0
  final double latitude;
  final double longitude;

  const BoardingPoint({
    required this.id,
    required this.name,
    required this.landmark,
    required this.time,
    required this.mapX,
    required this.mapY,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
  });
}

class DroppingPoint {
  final String id;
  final String name;
  final String landmark;
  final String eta;
  final double latitude;
  final double longitude;

  const DroppingPoint({
    required this.id,
    required this.name,
    required this.landmark,
    required this.eta,
    this.latitude = 13.0827,
    this.longitude = 80.2707,
  });
}

class CustomerReview {
  final String author;
  final double rating;
  final String comment;
  final String date;

  const CustomerReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class DriverInfo {
  final String name;
  final String contact;
  final double rating;
  final int experienceYears;

  const DriverInfo({
    required this.name,
    required this.contact,
    required this.rating,
    required this.experienceYears,
  });
}

class Seat {
  final String number;
  final bool isUpperDeck;
  final bool isBooked;
  final bool isSleeper;

  const Seat({
    required this.number,
    this.isUpperDeck = false,
    this.isBooked = false,
    this.isSleeper = false,
  });
}

class Bus {
  final String id;
  final String operatorName;
  final BusType busType;
  final String departureTime;
  final int departureHour;
  final String arrivalTime;
  final String duration;
  final double basePrice;
  final int seatsLeft;
  final double rating;
  final int reviewCount;
  final List<Amenity> amenities;
  final List<RestStop> restStops;
  final List<BoardingPoint> boardingPoints;
  final List<DroppingPoint> droppingPoints;
  final List<CustomerReview> reviews;
  final DriverInfo driver;
  final List<Seat> seats;

  const Bus({
    required this.id,
    required this.operatorName,
    required this.busType,
    required this.departureTime,
    required this.departureHour,
    required this.arrivalTime,
    required this.duration,
    required this.basePrice,
    required this.seatsLeft,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.restStops,
    required this.boardingPoints,
    required this.droppingPoints,
    required this.reviews,
    required this.driver,
    required this.seats,
  });

  bool get isSurgeActive => seatsLeft <= 5;
  double get effectiveSeatPrice => isSurgeActive ? basePrice * 1.20 : basePrice;
}

class Passenger {
  final String name;
  final int age;
  final String gender;
  final String contact;
  final bool isIdProofUploaded;
  final String? idFileName;

  Passenger({
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    this.isIdProofUploaded = false,
    this.idFileName,
  });
}

class BookingRecord {
  final String bookingId;
  final Bus bus;
  final String source;
  final String destination;
  final DateTime journeyDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final List<String> selectedSeats;
  final BoardingPoint boardingPoint;
  final DroppingPoint droppingPoint;
  final Passenger passenger;
  final bool hasStudentConcession;
  final bool hasRblCard;
  final double baseFare;
  final double surgeAmount;
  final double roundTripDiscount;
  final double studentDiscount;
  final double cashbackAmount;
  final double totalAmount;
  bool isCancelled;
  DateTime? rescheduledDate;
  String? rescheduledTimeSlot;

  BookingRecord({
    required this.bookingId,
    required this.bus,
    required this.source,
    required this.destination,
    required this.journeyDate,
    this.returnDate,
    required this.isRoundTrip,
    required this.selectedSeats,
    required this.boardingPoint,
    required this.droppingPoint,
    required this.passenger,
    required this.hasStudentConcession,
    required this.hasRblCard,
    required this.baseFare,
    required this.surgeAmount,
    required this.roundTripDiscount,
    required this.studentDiscount,
    required this.cashbackAmount,
    required this.totalAmount,
    this.isCancelled = false,
    this.rescheduledDate,
    this.rescheduledTimeSlot,
  });
}
