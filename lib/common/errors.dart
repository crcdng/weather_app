abstract class Failure {
  final String message;
  const Failure(this.message);
}

class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure() : super('City not found.');
}

class InvalidRequestFailure extends Failure {
  const InvalidRequestFailure() : super('Invalid Request.');
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure()
      : super(
            'Missing or incorrect API key. Check your API key and try again.');
}

class ServerFailure extends Failure {
  const ServerFailure() : super('Server error. Try again later.');
}

class ConnectionFailure extends Failure {
  const ConnectionFailure()
      : super('No conection to the server. Check your internet connection.');
}

// occurs when an empty string is sent
class InvalidRequestException implements Exception {} // 400

class ApiKeyException implements Exception {} // 401

// occurs while typing the city name
class CityNotFoundException implements Exception {} // 404

// 500 / other
class ServerException implements Exception {}
