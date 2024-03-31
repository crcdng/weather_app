import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/common/errors.dart';
import 'package:weather_app/domain/get_weather_usecase.dart';
import 'package:weather_app/domain/weather_entity.dart';
import 'package:weather_app/ui/weather_notifier.dart';

class MockGetWeatherUseCase extends Mock implements GetWeatherUsecase {}

void main() {
  late MockGetWeatherUseCase mockGetWeatherUseCase;
  late WeatherNotifier sut;

  const testCityName = "Berlin";
  const testNonCityName = "Beeeeerlin";

  const testWeatherEntity = WeatherEntity(
      city: "Berlin",
      main: "Clear",
      description: "clear sky",
      temperature: 22.91,
      pressure: 987,
      humidity: 60);

  setUp(() {
    mockGetWeatherUseCase = MockGetWeatherUseCase();
    sut = WeatherNotifier(usecase: mockGetWeatherUseCase);
  });

  test('should not set fields at the beginning', () async {
    expect(sut.weather, null);
    expect(sut.failure, null);
  });

  group('get current weather', () {
    test('should call the use case', () async {
      when(() => mockGetWeatherUseCase.call(city: testCityName))
          .thenAnswer((_) async => const Right(testWeatherEntity));

      await sut.getCurrentWeather(testCityName);

      verify(() => mockGetWeatherUseCase.call(city: testCityName)).called(1);
    });

    test('should notify listeners', () async {
      when(() => mockGetWeatherUseCase.call(city: testCityName))
          .thenAnswer((_) async => const Right(testWeatherEntity));

      var notified = false;
      sut.addListener(() {
        notified = true;
      });
      await sut.getCurrentWeather(testCityName);
      expect(notified, true);
    });

    test('should set the WeatherEntity field on successful call', () async {
      when(() => mockGetWeatherUseCase.call(city: testCityName))
          .thenAnswer((_) async => const Right(testWeatherEntity));

      await sut.getCurrentWeather(testCityName);

      expect(sut.weather, testWeatherEntity);
    });

    test('should set the Failure field on failure call', () async {
      when(() => mockGetWeatherUseCase.call(city: testNonCityName)).thenAnswer(
          (_) async => const Left(
              ServerFailure('The Open Weather API reported an error.')));

      await sut.getCurrentWeather(testNonCityName);

      expect(sut.failure,
          const ServerFailure('The Open Weather API reported an error.'));
    });
  });
}
