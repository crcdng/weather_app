import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/urls.dart';
import '../common/errors.dart';
import 'weather_model.dart';

class WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSource({required this.client});

  Future<WeatherModel> getCurrentWeather(String city) async {
    // This can be used to see the effect of the debounce mechanism in WeatherScreen
    // print("calling the API");
    final response =
        await client.get(Uri.parse(Urls.currentWeatherByCity(city)));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
