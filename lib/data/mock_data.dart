import '../models/models.dart';

class MockData {
  static List<Seat> generateSleeperSeats() {
    List<Seat> list = [];
    // Lower Deck: L1 to L15
    for (int i = 1; i <= 15; i++) {
      list.add(Seat(
        number: 'L$i',
        isUpperDeck: false,
        isBooked: i % 4 == 0,
        isSleeper: true,
      ));
    }
    // Upper Deck: U1 to U15
    for (int i = 1; i <= 15; i++) {
      list.add(Seat(
        number: 'U$i',
        isUpperDeck: true,
        isBooked: i % 3 == 0,
        isSleeper: true,
      ));
    }
    return list;
  }

  static List<Seat> generateSeaterSeats({int bookedFrequency = 5}) {
    List<Seat> list = [];
    for (int i = 1; i <= 36; i++) {
      list.add(Seat(
        number: '$i',
        isUpperDeck: false,
        isBooked: i % bookedFrequency == 0,
        isSleeper: false,
      ));
    }
    return list;
  }

  static List<Seat> generateNearlyFullSeats() {
    List<Seat> list = [];
    for (int i = 1; i <= 30; i++) {
      // Keep only 4 seats available (seats 3, 11, 19, 27)
      bool available = (i == 3 || i == 11 || i == 19 || i == 27);
      list.add(Seat(
        number: 'S$i',
        isUpperDeck: i > 15,
        isBooked: !available,
        isSleeper: true,
      ));
    }
    return list;
  }

  static final List<Bus> buses = [
    // 1. AC Sleeper (Regular)
    Bus(
      id: 'BUS-101',
      operatorName: 'IntrCity SmartBus',
      busType: BusType.acSleeper,
      departureTime: '21:30',
      departureHour: 21,
      arrivalTime: '06:00',
      duration: '8h 30m',
      basePrice: 1100.0,
      seatsLeft: 12,
      rating: 4.8,
      reviewCount: 420,
      amenities: [
        Amenity.chargingPoint,
        Amenity.blanket,
        Amenity.waterBottle,
        Amenity.tv,
      ],
      restStops: [
        RestStop(name: 'Food Plaza Express Highway', eta: '23:45', duration: '25 mins'),
        RestStop(name: 'Midway Oasis Oasis Rest Stop', eta: '03:15', duration: '15 mins'),
      ],
      boardingPoints: [
        BoardingPoint(id: 'BP1', name: 'Majestic Bus Terminal', landmark: 'Platform 8B, Opp Metro Gate 3', time: '21:30', mapX: 0.25, mapY: 0.35),
        BoardingPoint(id: 'BP2', name: 'Koramangala Sony Signal', landmark: 'Near Indian Oil Petrol Pump', time: '22:00', mapX: 0.55, mapY: 0.50),
        BoardingPoint(id: 'BP3', name: 'Electronic City Toll Gate', landmark: 'Flyover entrance bay', time: '22:30', mapX: 0.80, mapY: 0.75),
      ],
      droppingPoints: [
        DroppingPoint(id: 'DP1', name: 'Guindy Junction', landmark: 'Near Metro Station', eta: '05:15'),
        DroppingPoint(id: 'DP2', name: 'Koyambedu CMBT', landmark: 'Omni Bus Stand Gate 2', eta: '06:00'),
      ],
      reviews: [
        CustomerReview(author: 'Rohan Sharma', rating: 5.0, comment: 'Punctual, clean bedsheets and smooth driving on highway.', date: '2 days ago'),
        CustomerReview(author: 'Pooja Iyer', rating: 4.5, comment: 'AC temperature was maintained well. USB charging worked perfectly.', date: '1 week ago'),
      ],
      driver: DriverInfo(name: 'Rajesh Kumar', contact: '+91 98765 43210', rating: 4.9, experienceYears: 11),
      seats: generateSleeperSeats(),
    ),

    // 2. Volvo Multi-Axle (Nearly Full - 4 seats left -> Dynamic surge active!)
    Bus(
      id: 'BUS-202',
      operatorName: 'Orange Travels Gold Class',
      busType: BusType.volvo,
      departureTime: '22:15',
      departureHour: 22,
      arrivalTime: '06:30',
      duration: '8h 15m',
      basePrice: 1350.0,
      seatsLeft: 4, // 5 or fewer -> triggers 20% surge
      rating: 4.7,
      reviewCount: 310,
      amenities: [
        Amenity.chargingPoint,
        Amenity.blanket,
        Amenity.waterBottle,
      ],
      restStops: [
        RestStop(name: 'Highway Toll Food Court', eta: '00:30', duration: '20 mins'),
      ],
      boardingPoints: [
        BoardingPoint(id: 'BP4', name: 'Anand Rao Circle', landmark: 'Behind SRS Travels', time: '22:15', mapX: 0.30, mapY: 0.28),
        BoardingPoint(id: 'BP5', name: 'Madiwala St. Johns Hospital', landmark: 'Main Gate Waiting Bay', time: '22:45', mapX: 0.62, mapY: 0.58),
        BoardingPoint(id: 'BP6', name: 'Bommasandra Industrial Area', landmark: 'Opposite Metro Pillar 42', time: '23:15', mapX: 0.85, mapY: 0.82),
      ],
      droppingPoints: [
        DroppingPoint(id: 'DP3', name: 'Perungalathur', landmark: 'Near Bus Stop Flyover', eta: '05:45'),
        DroppingPoint(id: 'DP4', name: 'Chennai Central Station', landmark: 'Outside Gate 1', eta: '06:30'),
      ],
      reviews: [
        CustomerReview(author: 'Vikas Patel', rating: 4.8, comment: 'Extremely comfortable Volvo B11R ride. Arrived 10 mins early!', date: '3 days ago'),
        CustomerReview(author: 'Ananya Roy', rating: 4.6, comment: 'Staff was very polite and helpful with luggage.', date: '4 days ago'),
      ],
      driver: DriverInfo(name: 'Mahesh Reddy', contact: '+91 98451 23456', rating: 4.8, experienceYears: 9),
      seats: generateNearlyFullSeats(),
    ),

    // 3. AC Seater (Morning Bus)
    Bus(
      id: 'BUS-303',
      operatorName: 'Zingbus Premium',
      busType: BusType.seater,
      departureTime: '07:30',
      departureHour: 7,
      arrivalTime: '14:45',
      duration: '7h 15m',
      basePrice: 650.0,
      seatsLeft: 18,
      rating: 4.4,
      reviewCount: 180,
      amenities: [
        Amenity.chargingPoint,
        Amenity.waterBottle,
      ],
      restStops: [
        RestStop(name: 'Breakfast Point Shoolagiri', eta: '09:15', duration: '30 mins'),
        RestStop(name: 'Coffee Day Highway Express', eta: '12:00', duration: '15 mins'),
      ],
      boardingPoints: [
        BoardingPoint(id: 'BP7', name: 'Indiranagar Metro Station', landmark: 'Opposite KFC Exit B', time: '07:30', mapX: 0.45, mapY: 0.40),
        BoardingPoint(id: 'BP8', name: 'Silk Board Junction', landmark: 'Near Flyover Service Road', time: '08:00', mapX: 0.70, mapY: 0.65),
      ],
      droppingPoints: [
        DroppingPoint(id: 'DP5', name: 'Sriperumbudur Toll', landmark: 'Main Gate Toll Plaza', eta: '13:45'),
        DroppingPoint(id: 'DP6', name: 'Koyambedu Market', landmark: 'Gate 4 Platform', eta: '14:45'),
      ],
      reviews: [
        CustomerReview(author: 'Karthik N', rating: 4.5, comment: 'Clean seats, good breakfast halt stop.', date: '5 days ago'),
      ],
      driver: DriverInfo(name: 'Suresh Gowda', contact: '+91 97312 34567', rating: 4.6, experienceYears: 7),
      seats: generateSeaterSeats(),
    ),

    // 4. Ordinary (Express)
    Bus(
      id: 'BUS-404',
      operatorName: 'State Express Transport (SETC)',
      busType: BusType.ordinary,
      departureTime: '14:00',
      departureHour: 14,
      arrivalTime: '22:30',
      duration: '8h 30m',
      basePrice: 380.0,
      seatsLeft: 22,
      rating: 3.9,
      reviewCount: 520,
      amenities: [],
      restStops: [
        RestStop(name: 'State Highway Motel', eta: '17:30', duration: '20 mins'),
      ],
      boardingPoints: [
        BoardingPoint(id: 'BP9', name: 'Shantinagar Bus Stand', landmark: 'Platform 3 Local Gate', time: '14:00', mapX: 0.35, mapY: 0.38),
        BoardingPoint(id: 'BP10', name: 'Hosur Bus Stop', landmark: 'Flyover Underpass', time: '15:15', mapX: 0.75, mapY: 0.70),
      ],
      droppingPoints: [
        DroppingPoint(id: 'DP7', name: 'Tambaram East', landmark: 'Railway Station Stand', eta: '21:45'),
        DroppingPoint(id: 'DP8', name: 'Koyambedu CMBT', landmark: 'SETC Terminus', eta: '22:30'),
      ],
      reviews: [
        CustomerReview(author: 'Mani K.', rating: 4.0, comment: 'Very affordable ticket, on-time arrival.', date: '1 week ago'),
      ],
      driver: DriverInfo(name: 'Murugan V', contact: '+91 94432 10987', rating: 4.3, experienceYears: 14),
      seats: generateSeaterSeats(bookedFrequency: 4),
    ),

    // 5. Volvo AC Sleeper (Evening Luxury)
    Bus(
      id: 'BUS-505',
      operatorName: 'VRL Travels Executive',
      busType: BusType.volvo,
      departureTime: '18:45',
      departureHour: 18,
      arrivalTime: '03:30',
      duration: '8h 45m',
      basePrice: 1250.0,
      seatsLeft: 14,
      rating: 4.6,
      reviewCount: 380,
      amenities: [
        Amenity.chargingPoint,
        Amenity.blanket,
        Amenity.waterBottle,
        Amenity.tv,
      ],
      restStops: [
        RestStop(name: 'Saravana Bhavan Highway', eta: '21:00', duration: '30 mins'),
      ],
      boardingPoints: [
        BoardingPoint(id: 'BP11', name: 'Yeshwanthpur Govardhan', landmark: 'Opposite Railway Station', time: '18:45', mapX: 0.20, mapY: 0.20),
        BoardingPoint(id: 'BP12', name: 'Kalasipalyam VRL Office', landmark: 'Near Bus Stand Tower', time: '19:30', mapX: 0.40, mapY: 0.45),
      ],
      droppingPoints: [
        DroppingPoint(id: 'DP9', name: 'Ashok Pillar', landmark: 'Main Circle Bus Stop', eta: '03:00'),
        DroppingPoint(id: 'DP10', name: 'Egmore Railway Station', landmark: 'Gate 2 Bay', eta: '03:30'),
      ],
      reviews: [
        CustomerReview(author: 'Deepak S', rating: 4.7, comment: 'Very clean luxury sleeper, comfortable mattresses.', date: '3 days ago'),
      ],
      driver: DriverInfo(name: 'Chandrashekar B', contact: '+91 99001 23456', rating: 4.7, experienceYears: 10),
      seats: generateSleeperSeats(),
    ),

    // 6. AC Seater (Night Express)
    Bus(
      id: 'BUS-606',
      operatorName: 'KSRTC Airavat Club Class',
      busType: BusType.seater,
      departureTime: '23:00',
      departureHour: 23,
      arrivalTime: '06:15',
      duration: '7h 15m',
      basePrice: 790.0,
      seatsLeft: 9,
      rating: 4.5,
      reviewCount: 650,
      amenities: [
        Amenity.chargingPoint,
        Amenity.waterBottle,
        Amenity.blanket,
      ],
      restStops: [
        RestStop(name: 'Chittoor Highway Grand Plaza', eta: '01:30', duration: '20 mins'),
      ],
      boardingPoints: [
        BoardingPoint(id: 'BP13', name: 'Majestic KSRTC Terminal 1', landmark: 'Platform 12 Airavat Lounge', time: '23:00', mapX: 0.25, mapY: 0.35),
        BoardingPoint(id: 'BP14', name: 'Tin Factory Bus Bay', landmark: 'Near Footover Bridge', time: '23:35', mapX: 0.65, mapY: 0.42),
      ],
      droppingPoints: [
        DroppingPoint(id: 'DP11', name: 'Poonamallee Bypass', landmark: 'Near Toll Junction', eta: '05:30'),
        DroppingPoint(id: 'DP12', name: 'Koyambedu CMBT Terminal', landmark: 'Bay 5', eta: '06:15'),
      ],
      reviews: [
        CustomerReview(author: 'Praveen Rao', rating: 4.6, comment: 'Government Volvo service is reliable and comfortable.', date: '6 days ago'),
      ],
      driver: DriverInfo(name: 'Gopal Krishna', contact: '+91 98801 87654', rating: 4.8, experienceYears: 12),
      seats: generateSeaterSeats(),
    ),
  ];

  static (double, double) getCoordinatesForCity(String city) {
    final lower = city.toLowerCase().trim();
    if (lower.contains('mumbai') || lower.contains('bombay')) return (19.0760, 72.8777);
    if (lower.contains('delhi') || lower.contains('dilli')) return (28.6139, 77.2090);
    if (lower.contains('bengaluru') || lower.contains('bangalore')) return (12.9716, 77.5946);
    if (lower.contains('chennai') || lower.contains('madras')) return (13.0827, 80.2707);
    if (lower.contains('pune')) return (18.5204, 73.8567);
    if (lower.contains('hyderabad')) return (17.3850, 78.4867);
    if (lower.contains('kolkata') || lower.contains('calcutta')) return (22.5726, 88.3639);
    if (lower.contains('ahmedabad')) return (23.0225, 72.5714);
    if (lower.contains('jaipur')) return (26.9124, 75.7873);
    if (lower.contains('surat')) return (21.1702, 72.8311);
    if (lower.contains('lucknow')) return (26.8467, 80.9462);
    if (lower.contains('kanpur')) return (26.4499, 80.3319);
    if (lower.contains('nagpur')) return (21.1458, 79.0882);
    if (lower.contains('indore')) return (22.7196, 75.8577);
    if (lower.contains('bhopal')) return (23.2599, 77.4126);
    if (lower.contains('patna')) return (25.5941, 85.1376);
    if (lower.contains('chandigarh')) return (30.7333, 76.7794);
    if (lower.contains('goa') || lower.contains('panaji')) return (15.2993, 74.1240);
    if (lower.contains('kochi') || lower.contains('cochin')) return (9.9312, 76.2673);
    if (lower.contains('coimbatore')) return (11.0168, 76.9558);
    if (lower.contains('mysore')) return (12.2958, 76.6394);
    return (12.9716, 77.5946);
  }

  static List<BoardingPoint> getBoardingPointsForCity(String city) {
    final lower = city.toLowerCase().trim();
    if (lower.contains('mumbai') || lower.contains('bombay')) {
      return const [
        BoardingPoint(id: 'BP1', name: 'Dadar TT Circle', landmark: 'Opposite Pritam Hotel', time: '21:30', mapX: 0.25, mapY: 0.35, latitude: 19.0178, longitude: 72.8478),
        BoardingPoint(id: 'BP2', name: 'Sion Circle Flyover', landmark: 'Near Cinemax Cinema', time: '21:55', mapX: 0.45, mapY: 0.45, latitude: 19.0434, longitude: 72.8634),
        BoardingPoint(id: 'BP3', name: 'Chembur Diamond Garden', landmark: 'Bus Waiting Bay', time: '22:15', mapX: 0.60, mapY: 0.55, latitude: 19.0522, longitude: 72.8994),
        BoardingPoint(id: 'BP4', name: 'Vashi Old Toll Plaza', landmark: 'Sion-Panvel Highway Bay', time: '22:45', mapX: 0.75, mapY: 0.70, latitude: 19.0771, longitude: 72.9986),
        BoardingPoint(id: 'BP5', name: 'Borivali National Park', landmark: 'Western Express Highway Gate', time: '23:15', mapX: 0.85, mapY: 0.85, latitude: 19.2288, longitude: 72.8541),
      ];
    } else if (lower.contains('delhi') || lower.contains('dilli')) {
      return const [
        BoardingPoint(id: 'BP1', name: 'Kashmere Gate ISBT', landmark: 'Platform 8, Metro Gate 1', time: '21:30', mapX: 0.25, mapY: 0.35, latitude: 28.6675, longitude: 77.2335),
        BoardingPoint(id: 'BP2', name: 'Karol Bagh Metro', landmark: 'Pillar 120, Pusa Road', time: '21:55', mapX: 0.45, mapY: 0.45, latitude: 28.6441, longitude: 77.1888),
        BoardingPoint(id: 'BP3', name: 'Dhaula Kuan Junction', landmark: 'Near Airport Express Metro', time: '22:20', mapX: 0.60, mapY: 0.55, latitude: 28.5921, longitude: 77.1617),
        BoardingPoint(id: 'BP4', name: 'AIIMS Ring Road Flyover', landmark: 'Under Flyover Bus Bay', time: '22:45', mapX: 0.75, mapY: 0.70, latitude: 28.5672, longitude: 77.2100),
        BoardingPoint(id: 'BP5', name: 'Anand Vihar ISBT', landmark: 'Opposite Railway Concourse', time: '23:15', mapX: 0.85, mapY: 0.85, latitude: 28.6469, longitude: 77.3160),
      ];
    } else if (lower.contains('pune')) {
      return const [
        BoardingPoint(id: 'BP1', name: 'Swargate Bus Stand', landmark: 'Near Laxmi Narayan Theater', time: '21:30', mapX: 0.25, mapY: 0.35, latitude: 18.5018, longitude: 73.8586),
        BoardingPoint(id: 'BP2', name: 'Shivaji Nagar Station', landmark: 'Platform 2 Exit Gate', time: '22:00', mapX: 0.50, mapY: 0.50, latitude: 18.5314, longitude: 73.8446),
        BoardingPoint(id: 'BP3', name: 'Wakad Hinjewadi Bridge', landmark: 'Ginger Hotel Service Road', time: '22:35', mapX: 0.80, mapY: 0.75, latitude: 18.5987, longitude: 73.7680),
      ];
    } else if (lower.contains('hyderabad')) {
      return const [
        BoardingPoint(id: 'BP1', name: 'MGBS Imlibun Terminal', landmark: 'Platform 18 Intercity Bay', time: '21:30', mapX: 0.25, mapY: 0.35, latitude: 17.3786, longitude: 78.4815),
        BoardingPoint(id: 'BP2', name: 'Ameerpet Metro Pillar 104', landmark: 'Opposite Big Bazaar', time: '22:05', mapX: 0.55, mapY: 0.50, latitude: 17.4375, longitude: 78.4482),
        BoardingPoint(id: 'BP3', name: 'Gachibowli Outer Ring Road', landmark: 'Near Biodiversity Park', time: '22:40', mapX: 0.80, mapY: 0.75, latitude: 17.4401, longitude: 78.3489),
      ];
    } else if (lower.contains('chennai')) {
      return const [
        BoardingPoint(id: 'BP1', name: 'Koyambedu CMBT', landmark: 'Omni Bus Stand Platform 3', time: '21:30', mapX: 0.25, mapY: 0.35, latitude: 13.0694, longitude: 80.2078),
        BoardingPoint(id: 'BP2', name: 'Guindy Kathipara Junction', landmark: 'Near Metro Station Gate 2', time: '22:00', mapX: 0.55, mapY: 0.55, latitude: 13.0067, longitude: 80.2003),
        BoardingPoint(id: 'BP3', name: 'Perungalathur Bypass', landmark: 'Near Bus Stop Flyover', time: '22:35', mapX: 0.80, mapY: 0.75, latitude: 12.9054, longitude: 80.0931),
      ];
    }

    final coords = getCoordinatesForCity(city);
    return [
      BoardingPoint(id: 'BP1', name: '$city Central Terminus', landmark: 'Main Intercity Platform 1', time: '21:30', mapX: 0.25, mapY: 0.35, latitude: coords.$1, longitude: coords.$2),
      BoardingPoint(id: 'BP2', name: '$city City Center Circle', landmark: 'Near Clock Tower Square', time: '22:00', mapX: 0.55, mapY: 0.50, latitude: coords.$1 + 0.02, longitude: coords.$2 + 0.02),
      BoardingPoint(id: 'BP3', name: '$city Expressway Toll Plaza', landmark: 'Highway Entry Toll Gate', time: '22:35', mapX: 0.80, mapY: 0.75, latitude: coords.$1 + 0.05, longitude: coords.$2 + 0.05),
    ];
  }

  static List<DroppingPoint> getDroppingPointsForCity(String city) {
    final lower = city.toLowerCase().trim();
    if (lower.contains('delhi') || lower.contains('dilli')) {
      return const [
        DroppingPoint(id: 'DP1', name: 'Dhaula Kuan Metro', landmark: 'Airport Express Underpass', eta: '05:30', latitude: 28.5921, longitude: 77.1617),
        DroppingPoint(id: 'DP2', name: 'Kashmere Gate ISBT', landmark: 'Interstate Bus Stand Gate 2', eta: '06:15', latitude: 28.6675, longitude: 77.2335),
        DroppingPoint(id: 'DP3', name: 'Anand Vihar ISBT', landmark: 'Terminal Gate 4', eta: '07:00', latitude: 28.6469, longitude: 77.3160),
      ];
    } else if (lower.contains('mumbai') || lower.contains('bombay')) {
      return const [
        DroppingPoint(id: 'DP1', name: 'Borivali National Park', landmark: 'WE Highway Gate', eta: '05:15', latitude: 19.2288, longitude: 72.8541),
        DroppingPoint(id: 'DP2', name: 'Dadar TT Circle', landmark: 'Pritam Hotel Bay', eta: '06:00', latitude: 19.0178, longitude: 72.8478),
        DroppingPoint(id: 'DP3', name: 'Vashi Highway Toll', landmark: 'Plaza Waiting Bay', eta: '06:30', latitude: 19.0771, longitude: 72.9986),
      ];
    } else if (lower.contains('chennai')) {
      return const [
        DroppingPoint(id: 'DP1', name: 'Guindy Kathipara', landmark: 'Metro Station Gate 1', eta: '05:15', latitude: 13.0067, longitude: 80.2003),
        DroppingPoint(id: 'DP2', name: 'Koyambedu CMBT', landmark: 'Omni Bus Stand Gate 2', eta: '06:00', latitude: 13.0694, longitude: 80.2078),
      ];
    }

    final coords = getCoordinatesForCity(city);
    return [
      DroppingPoint(id: 'DP1', name: '$city Highway Toll Gate', landmark: 'Bypass Flyover Drop Point', eta: '05:30', latitude: coords.$1 - 0.04, longitude: coords.$2 - 0.04),
      DroppingPoint(id: 'DP2', name: '$city Central Bus Terminus', landmark: 'Main Passenger Concourse', eta: '06:15', latitude: coords.$1, longitude: coords.$2),
    ];
  }

  static List<Bus> getBusesForRoute(String source, String destination) {
    final customBoarding = getBoardingPointsForCity(source);
    final customDropping = getDroppingPointsForCity(destination);

    return buses.map((bus) {
      return Bus(
        id: bus.id,
        operatorName: bus.operatorName,
        busType: bus.busType,
        departureTime: bus.departureTime,
        departureHour: bus.departureHour,
        arrivalTime: bus.arrivalTime,
        duration: bus.duration,
        basePrice: bus.basePrice,
        seatsLeft: bus.seatsLeft,
        rating: bus.rating,
        reviewCount: bus.reviewCount,
        amenities: bus.amenities,
        restStops: [
          RestStop(name: '$source-$destination Highway Oasis', eta: '01:00', duration: '25 mins'),
          RestStop(name: 'Midway Express Halt', eta: '03:30', duration: '15 mins'),
        ],
        boardingPoints: customBoarding,
        droppingPoints: customDropping,
        reviews: bus.reviews,
        driver: bus.driver,
        seats: bus.seats,
      );
    }).toList();
  }
}
