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
    expect(sut.weatherEntity, null);
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
      expect(notified, equals(true));
    });

    test('should set the WeatherEntity field only on successful call',
        () async {
      when(() => mockGetWeatherUseCase.call(city: testCityName))
          .thenAnswer((_) async => const Right(testWeatherEntity));

      await sut.getCurrentWeather(testCityName);

      expect(sut.weatherEntity, equals(testWeatherEntity));
      expect(sut.failure, equals(null));
    });

    test('should set the Failure field only on CityNotFoundFailure', () async {
      when(() => mockGetWeatherUseCase.call(city: testNonCityName))
          .thenAnswer((_) async => const Left(CityNotFoundFailure()));

      await sut.getCurrentWeather(testNonCityName);

      expect(sut.weatherEntity, equals(null));
      expect(sut.failure, equals(const CityNotFoundFailure()));
    });

    test('should set the Failure field only on ApiKeyFailure', () async {
      when(() => mockGetWeatherUseCase.call(city: testNonCityName))
          .thenAnswer((_) async => const Left(ApiKeyFailure()));

      await sut.getCurrentWeather(testNonCityName);

      expect(sut.weatherEntity, equals(null));
      expect(sut.failure, equals(const ApiKeyFailure()));
    });

    test('should set the Failure field only on ServerFailure', () async {
      when(() => mockGetWeatherUseCase.call(city: testNonCityName))
          .thenAnswer((_) async => const Left(ServerFailure()));

      await sut.getCurrentWeather(testNonCityName);

      expect(sut.weatherEntity, equals(null));
      expect(sut.failure, equals(const ServerFailure()));
    });

    test('should set the Failure field only on ConnectionFailure', () async {
      when(() => mockGetWeatherUseCase.call(city: testNonCityName))
          .thenAnswer((_) async => const Left(ConnectionFailure()));

      await sut.getCurrentWeather(testNonCityName);

      expect(sut.weatherEntity, equals(null));
      expect(sut.failure, equals(const ConnectionFailure()));
    });
  });
}
