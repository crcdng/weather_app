import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/common/errors.dart';
import 'package:weather_app/data/remote_datasource.dart';
import 'package:weather_app/data/weather_model.dart';
import 'package:weather_app/data/weather_repository_impl.dart';
import 'package:weather_app/domain/weather_entity.dart';
import 'package:weather_app/domain/weather_repository.dart';

class MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

void main() {
  late WeatherRepositoryImpl sut;
  late MockWeatherRemoteDataSource mockWeatherRemoteDataSource;
  const testCityName = "Berlin";
  const testNonCityName = "Beeeeerlin";

  const testWeatherModel = WeatherModel(
      city: "Berlin",
      main: "Clear",
      description: "clear sky",
      temperature: 22.91,
      pressure: 987,
      humidity: 60);

  const testWeatherEntity = WeatherEntity(
      city: "Berlin",
      main: "Clear",
      description: "clear sky",
      temperature: 22.91,
      pressure: 987,
      humidity: 60);

  setUp(() {
    mockWeatherRemoteDataSource = MockWeatherRemoteDataSource();
    sut = WeatherRepositoryImpl(remoteDataSource: mockWeatherRemoteDataSource);
  });

  test('should be a subclass of WeatherRepository', () {
    expect(sut, isA<WeatherRepository>());
  });

  group('get current weather', () {
    test(
      'should return the current weather when a call to data source is successful',
      () async {
        when(() => mockWeatherRemoteDataSource.getCurrentWeather(testCityName))
            .thenAnswer((_) async => testWeatherModel);

        final result = await sut.getCurrentWeather(testCityName);

        expect(result, equals(const Right(testWeatherEntity)));
      },
    );

    test(
      'should return a CityNotFoundFailure when a CityNotFoundException is thrown',
      () async {
        when(() =>
                mockWeatherRemoteDataSource.getCurrentWeather(testNonCityName))
            .thenThrow(CityNotFoundException());

        final result = await sut.getCurrentWeather(testNonCityName);

        expect(result, equals(const Left(CityNotFoundFailure())));
      },
    );

    test(
      'should return a ApiKeyFailure failure when a ApiKeyException is thrown',
      () async {
        when(() => mockWeatherRemoteDataSource.getCurrentWeather(testCityName))
            .thenThrow(ApiKeyException());

        final result = await sut.getCurrentWeather(testCityName);

        expect(result, equals(const Left(ApiKeyFailure())));
      },
    );

    test(
      'should return a ServerFailure when a ServerException is thrown',
      () async {
        when(() => mockWeatherRemoteDataSource.getCurrentWeather(testCityName))
            .thenThrow(ServerException());

        final result = await sut.getCurrentWeather(testCityName);

        expect(result, equals(const Left(ServerFailure())));
      },
    );

    test(
      'should return a connection failure when a SocketException is thrown / the device has no internet',
      () async {
        when(() =>
                mockWeatherRemoteDataSource.getCurrentWeather(testNonCityName))
            .thenThrow(const SocketException('Socket connection error.'));

        final result = await sut.getCurrentWeather(testNonCityName);

        expect(result, equals(const Left(ConnectionFailure())));
      },
    );
  });
}
