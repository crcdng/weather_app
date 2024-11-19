import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weather_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // NOTE these tests call the remote API which requires an API key therefore they must be run from the command line with
  // "flutter test integration_test --dart-define OWM_API_KEY=<API KEY>"
  // running the tests from the Testing tab in VSCode results in failure

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

    testWidgets('enter city, receive the weather, update the city',
        (tester) async {
      await tester.pumpWidget(const MainApp());

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, "Berlin");
      // debounce function requires to wait a bit
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('weather_data')), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.enterText(textField, "");
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('weather_data')), findsNothing);

      await tester.enterText(textField, "Boston");
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('weather_data')), findsOneWidget);
    });
  });
}
