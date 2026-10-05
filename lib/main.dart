import 'package:flutter/material.dart';
import 'screens/bus_search_screen.dart';

void main() {
  runApp(const RedBusApp());
}

class RedBusApp extends StatelessWidget {
  const RedBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laal Pari - Intercity Bus Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD84E55),
          primary: const Color(0xFFD84E55),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD84E55),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD84E55),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const BusSearchScreen(),
    );
  }
}
