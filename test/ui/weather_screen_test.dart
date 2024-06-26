import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/errors.dart';
import 'package:weather_app/domain/get_weather_usecase.dart';
import 'package:weather_app/domain/weather_entity.dart';
import 'package:weather_app/ui/weather_notifier.dart';
import 'package:weather_app/ui/weather_screen.dart';

class MockGetWeatherUseCase extends Mock implements GetWeatherUsecase {}

const testWeatherEntity = WeatherEntity(
    city: "Berlin",
    main: "Clear",
    description: "clear sky",
    temperature: 22.91,
    pressure: 987,
    humidity: 60);

// NOTE a notifier fake which needs to be instrumented in widget tests
class FakeWeatherNotifier extends WeatherNotifier {
  late final MockWeatherNotifier mockWeatherNotifier;
  Failure? instrumentedFailure;

  FakeWeatherNotifier({required this.mockWeatherNotifier})
      : super(usecase: MockGetWeatherUseCase());

  instrumentFailure(Failure failure) {
    instrumentedFailure = failure;
  }

  resetInstrumentedFailure() {
    instrumentedFailure = null;
  }

  @override
  Future<void> getCurrentWeather(String city) async {
    if (instrumentedFailure != null) {
      failure = instrumentedFailure;
    } else {
      weather = testWeatherEntity;
    }
    notifyListeners();
  }
}

class MockWeatherNotifier extends Mock {
  getCurrentWeather(city);
}

Widget _makeTestableWidget(Widget widget, WeatherNotifier weatherNotifierSpy) {
  return MaterialApp(
      home: Scaffold(
    body: ChangeNotifierProvider<WeatherNotifier>(
        create: (context) => weatherNotifierSpy, child: widget),
  ));
}

void main() {
  late MockWeatherNotifier mockWeatherNotifier;
  late FakeWeatherNotifier fakeWeatherNotifier;
  const testCityName = "Berlin";

  setUp(() {
    mockWeatherNotifier = MockWeatherNotifier();
    fakeWeatherNotifier =
        FakeWeatherNotifier(mockWeatherNotifier: mockWeatherNotifier);
  });

  testWidgets('should have a textfield that allows text entry', (tester) async {
    when(() => mockWeatherNotifier.getCurrentWeather(testCityName))
        .thenAnswer((_) async => null);
    fakeWeatherNotifier.resetInstrumentedFailure();
    await tester.pumpWidget(
        _makeTestableWidget(const WeatherScreen(), fakeWeatherNotifier));
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    await tester.enterText(textField, "Berlin");
    await tester.pump();
    expect(find.text("Berlin"), findsOneWidget);
  });

  group('get weather', () {
    testWidgets('should not show weather data when nothing is entered',
        (tester) async {
      when(() => mockWeatherNotifier.getCurrentWeather(testCityName))
          .thenAnswer((invocation) async => null);
      fakeWeatherNotifier.resetInstrumentedFailure();
      await tester.pumpWidget(
          _makeTestableWidget(const WeatherScreen(), fakeWeatherNotifier));
      expect(find.byKey(const Key('weather_data')), findsNothing);
    });

    testWidgets('should show weather data when call is successful',
        (tester) async {
      when(() => mockWeatherNotifier.getCurrentWeather(testCityName))
          .thenAnswer((invocation) async {});
      fakeWeatherNotifier.resetInstrumentedFailure();
      await tester.pumpWidget(
          _makeTestableWidget(const WeatherScreen(), fakeWeatherNotifier));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, "Berlin");
      // debounce function requires to wait a bit
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('weather_data')), findsOneWidget);
    });
  });

  group('failures getting the weather', () {
    testWidgets('should not show a message when a CityNotFoundFailure occurs',
        (tester) async {
      when(() => mockWeatherNotifier.getCurrentWeather(testCityName))
          .thenAnswer((invocation) async {});
      fakeWeatherNotifier.instrumentFailure(const CityNotFoundFailure());
      await tester.pumpWidget(
          _makeTestableWidget(const WeatherScreen(), fakeWeatherNotifier));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, "Berlin");
      // debounce function requires to wait a bit
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('error_message')), findsNothing);
    });

    testWidgets('should show a message when a ApiKeyFailure occurs',
        (tester) async {
      when(() => mockWeatherNotifier.getCurrentWeather(testCityName))
          .thenAnswer((invocation) async {});
      fakeWeatherNotifier.instrumentFailure(const ApiKeyFailure());
      await tester.pumpWidget(
          _makeTestableWidget(const WeatherScreen(), fakeWeatherNotifier));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, "Berlin");
      // debounce function requires to wait a bit
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('error_message')), findsOneWidget);
      expect(find.text(const ApiKeyFailure().message), findsOneWidget);
    });

    testWidgets('should show a message when a ServerFailure occurs',
        (tester) async {
      when(() => mockWeatherNotifier.getCurrentWeather(testCityName))
          .thenAnswer((invocation) async {});
      fakeWeatherNotifier.instrumentFailure(const ServerFailure());
      await tester.pumpWidget(
          _makeTestableWidget(const WeatherScreen(), fakeWeatherNotifier));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, "Berlin");
      // debounce function requires to wait a bit
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('error_message')), findsOneWidget);
      expect(find.text(const ServerFailure().message), findsOneWidget);
    });

    testWidgets('should show a message when a ConnectionFailure occurs',
        (tester) async {
      when(() => mockWeatherNotifier.getCurrentWeather(testCityName))
          .thenAnswer((invocation) async {});
      fakeWeatherNotifier.instrumentFailure(const ConnectionFailure());
      await tester.pumpWidget(
          _makeTestableWidget(const WeatherScreen(), fakeWeatherNotifier));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, "Berlin");
      // debounce function requires to wait a bit
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('error_message')), findsOneWidget);
      expect(find.text(const ConnectionFailure().message), findsOneWidget);
    });
  });
}
