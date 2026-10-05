import 'package:flutter_test/flutter_test.dart';
import 'package:redbus_app/main.dart';

void main() {
  testWidgets('RedBus App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RedBusApp());
    expect(find.text('RedBus Intercity Bus Booking'), findsOneWidget);
    expect(find.text('Search Buses'), findsOneWidget);
  });
}
