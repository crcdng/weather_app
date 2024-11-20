import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/data/weather_model.dart';
import 'package:weather_app/domain/weather_entity.dart';

import '../utils/read_json.dart';

void main() {
  late WeatherModel sut;

  const testWeatherModel = WeatherModel(
      city: "Berlin",
      main: "Clear",
      description: "clear sky",
      temperature: 22.91,
      pressure: 987,
      humidity: 60);

  final Map<String, dynamic> testJsonMap =
      json.decode(readJson('test/utils/weather_response.json'))
          as Map<String, dynamic>;

  setUp(() {
    sut = testWeatherModel;
  });

  test('should be a subclass of WeatherEntity', () {
    expect(sut, isA<WeatherEntity>());
  });

  test('should return a valid model from JSON', () async {
    final model = WeatherModel.fromJson(testJsonMap);

    // WeatherModel instances must be comparable for this test to succeed
    expect(sut, equals(model));
  });
}
