import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/presentation/weather_notifier.dart';
import 'package:weather_app/presentation/weather_notifier_provider.dart';

class MockWeatherNotifier extends Mock implements WeatherNotifier {}

void main() {
  late MockWeatherNotifier mockWeatherNotifier;
  late WeatherNotifierProvider sut;

  setUp(() {
    mockWeatherNotifier = MockWeatherNotifier();
    sut = WeatherNotifierProvider(
        weatherNotifier: mockWeatherNotifier, child: const Placeholder());
  });

  test('extends Inherited Widget', () {
    expect(sut, isA<InheritedWidget>());
  });

  test('what else to test', () {
    throw UnimplementedError();
  });
}
