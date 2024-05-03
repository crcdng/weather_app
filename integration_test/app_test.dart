import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weather_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // note this test calls the remote API, therefore it must be run with
  // "flutter test integration_test --dart-define OWM_API_KEY=<API KEY>"

  group('end-to-end test', () {
    testWidgets('enter a city name and receive the weather', (tester) async {
      await tester.pumpWidget(const MainApp());

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, "Berlin");
      // debounce function requires to wait a bit
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('weather_data')), findsOneWidget);
    });
  });
}
