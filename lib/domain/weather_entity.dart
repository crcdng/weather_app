import 'package:equatable/equatable.dart';

class WeatherEntity with EquatableMixin {
  final String city;
  final String main;
  final String description;
  final double temperature;
  final int pressure;
  final int humidity;

  const WeatherEntity(
      {required this.city,
      required this.main,
      required this.description,
      required this.temperature,
      required this.pressure,
      required this.humidity});

  @override
  List<Object?> get props =>
      [city, main, description, temperature, pressure, humidity];
}
