import 'package:fpdart/fpdart.dart';

import '../common/errors.dart';
import 'weather_entity.dart';

abstract interface class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(String city);
}
