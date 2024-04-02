class Urls {
  static const String apiKey = String.fromEnvironment('OWM_API_KEY');

  static String currentWeatherByCity(String city) {
    return 'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey';
  }
}
