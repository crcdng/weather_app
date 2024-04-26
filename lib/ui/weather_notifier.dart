import 'package:flutter/foundation.dart';
import '../common/errors.dart';
import '../domain/get_weather_usecase.dart';
import '../domain/weather_entity.dart';

class WeatherNotifier with ChangeNotifier {
  final GetWeatherUsecase usecase;
  WeatherEntity? weather;
  Failure? failure;

  WeatherNotifier({required this.usecase});

  Future<void> getCurrentWeather(String city) async {
    final result = await usecase(city: city);
    result.fold((failure) {
      this.failure = failure;
    }, (data) {
      weather = data;
    });
    notifyListeners();
  }
}
