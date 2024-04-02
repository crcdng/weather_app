import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/urls.dart';
import '../common/errors.dart';
import 'weather_model.dart';

class WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSource({required this.client});

  Future<WeatherModel> getCurrentWeather(String city) async {
    // NOTE The next line can be used to illustrate the effect of the debounce mechanism in WeatherScreen
    // print("calling the API");
    final response =
        await client.get(Uri.parse(Urls.currentWeatherByCity(city)));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404 &&
        response.body.isNotEmpty &&
        json.decode(response.body)["message"] != null &&
        json.decode(response.body)["message"] == "city not found") {
      throw CityNotFoundException();
    } else if (response.statusCode == 401 &&
        response.body.isNotEmpty &&
        json.decode(response.body)["message"] != null &&
        json.decode(response.body)["message"].startsWith("Invalid API key.")) {
      throw ApiKeyException();
    } else {
      throw ServerException();
    }
    // NOTE SocketException (no Internet connection) is thrown elsewhere.
    // It is also handled in the repository.
  }
}
