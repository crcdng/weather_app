import 'package:flutter/material.dart';
import 'package:weather_app/ui/weather_notifier.dart';

class WeatherNotifierProvider extends InheritedWidget {
  final WeatherNotifier weatherNotifier;

  const WeatherNotifierProvider(
      {super.key, required this.weatherNotifier, required super.child});

  static WeatherNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WeatherNotifierProvider>()!
        .weatherNotifier;
  }

  @override
  bool updateShouldNotify(WeatherNotifierProvider oldWidget) {
    return weatherNotifier != oldWidget.weatherNotifier;
  }
}
