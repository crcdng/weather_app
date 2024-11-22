import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/common/errors.dart';
import 'package:weather_app/domain/get_weather_usecase.dart';
import 'package:weather_app/domain/weather_entity.dart';
import 'package:weather_app/domain/weather_repository.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockWeatherRepository;
  late GetWeatherUsecase sut; // sut for "system under test"

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
    mockWeatherRepository = MockWeatherRepository();
    sut = GetWeatherUsecase(repository: mockWeatherRepository);
  });

  test('should call the repository method', () async {
    when(() => mockWeatherRepository.getCurrentWeather(testCityName))
        .thenAnswer((_) async => const Right(testWeatherEntity));

    await sut.call(city: testCityName);

    verify(() => mockWeatherRepository.getCurrentWeather(testCityName))
        .called(1);
  });

  test('should pass the entity', () async {
    when(() => mockWeatherRepository.getCurrentWeather(testCityName))
        .thenAnswer((_) async => const Right(testWeatherEntity));

    final result = await sut.call(city: testCityName);

    expect(
        result, equals(const Right<Failure, WeatherEntity>(testWeatherEntity)));
  });

  test('should pass a failure when the API reports an error', () async {
    when(() => mockWeatherRepository.getCurrentWeather(testNonCityName))
        .thenAnswer((_) async => const Left(ServerFailure()));

    final result = await sut.call(city: testNonCityName);

    expect(result,
        equals(const Left<ServerFailure, WeatherEntity>(ServerFailure())));
  });
}
