import 'package:fpdart/fpdart.dart';
import '../common/errors.dart';
import 'weather_entity.dart';
import 'weather_repository.dart';

class GetWeatherUsecase {
  final WeatherRepository repository;
  GetWeatherUsecase({required this.repository});

  Future<Either<Failure, WeatherEntity>> call({required String city}) {
    return repository.getCurrentWeather(city);
  }
}
