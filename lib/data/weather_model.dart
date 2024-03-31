import 'package:weather_app/domain/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel(
      {required super.city,
      required super.main,
      required super.description,
      required super.temperature,
      required super.pressure,
      required super.humidity});

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
        city: json['name'] as String,
        main: json['weather'][0]['main'] as String,
        description: json['weather'][0]['description'] as String,
        temperature: json['main']['temp'] as double,
        pressure: json['main']['pressure'] as int,
        humidity: json['main']['humidity'] as int,
      );

  WeatherEntity toEntity() => WeatherEntity(
        city: city,
        main: main,
        description: description,
        temperature: temperature,
        pressure: pressure,
        humidity: humidity,
      );
}
