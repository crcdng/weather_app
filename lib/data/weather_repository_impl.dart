import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../common/errors.dart';
import '../domain/weather_entity.dart';
import '../domain/weather_repository.dart';
import 'remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(String city) async {
    try {
      final result = await remoteDataSource.getCurrentWeather(city);
      return Right(result.toEntity());
    } on InvalidRequestException {
      return const Left(InvalidRequestFailure());
    } on CityNotFoundException {
      return const Left(CityNotFoundFailure());
    } on ApiKeyException {
      return const Left(ApiKeyFailure());
    } on ServerException {
      return const Left(ServerFailure());
    } on SocketException {
      return const Left(ConnectionFailure());
    }
  }
}
