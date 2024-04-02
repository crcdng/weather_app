# Flutter Minimal Clean Architecture Example

This is a minimal example for clean architecture and test-driven development in Flutter. It fetches weather data for a city from [OpenWeatherMap](https://openweathermap.org) and displays it. It is adapted from [this tutorial](https://www.youtube.com/watch?v=g2Mup12MccU) by Flutter Guys - see other sources below.

## Architecture overview 

From top to bottom:

### UI layer

The `WeatherNotifier` is a ChangeNotifier from the [provider package](https://pub.dev/packages/provider). It has a `WeatherEntity` and gets a `GetWeatherUsecase` via the constructor. It calls the `GetWeatherUsecase` with the name of the city, sets the `WeatherEntity` and notifies the `Consumer` widget on our `WeatherScreen`.

The WeatherScreen hosts the `Consumer` widget and the `Provider.of<WeatherNotifier>(context, listen: false)` call to talk to the `WeatherNotifier`. A debounce mechanism limits the number of calls.

### Domain layer

Clean architecture dictates that this central layer does not depend either on the user interface (ui layer) or on the remote API (data layer). 

`WeatherEntity` is an immutable pure data class that contains the fields we are interested in. Although we don't test it directly it uses the equatable package so that instances of `WeatherModel` can be compared in tests. 

The `WeatherRepository` either returns a `Failure` object or a `WeatherEntity`. It is separated into an abstract class in the domain layer that defines the contract (interface) and a concrete class in the data layer that implements it. Because a higher layers normally depends on a lower layer this technique achieves a *dependency inversion*.

A use case represents a user action. The `GetWeatherUsecase` gets (the abstract) `WeatherRepository` passed in via the constructor and calls its method. 

Use cases are implemented as callable classes (with a call method) and common interface. This could be implemented with an abstract superclass and additional work on the parameters going into the call method, which I didn't do for brevity here.

### Data layer

The data layer is responsible to wrap remote or local data sources, here the [OpenWeatherMap API](https://openweathermap.org/current). 

The `WeatherModel` class extends `WeatherEntity`. It adds a constructor to create its instance from a subset of the JSON format that is coming from the `DataSource`. It also has a method to transform itself into a `WeatherEntity`. 

The `WeatherRemoteDataSource` takes an http client passed in its constructor and its method retuns a Future of a `WeatherModel` converted from JSON. To do this, it talks to the remote OpenWeatherMap API, for which you need to sign up for a free API key. I keep all the information necessary inside the `WeatherRemoteDataSource` class. As with `GetWeatherUsecase` above, I did not add another layer of abstraction by separating it into an abstract superclass and concrete subclass. 

The API call to retrieve the current weather for a city is returned in `constants.dart`: `https://api.openweathermap.org/data/2.5/weather?q=<CITY NAME>&units=metric&appid=<API KEY>`

I am adding the `units=metric` parameter retrieve the temperature in degree Celsius. Because the API key should not be stored in a code repository, it is injected from the environment. Therefore the app must be called like this:
`flutter run --dart-define OWM_API_KEY=<API KEY> --hot`. In production, the key would be provided by the user at the start of the app / in a settings screen.

There are various issues around handling API keys in Flutter, see: https://codewithandrea.com/articles/flutter-api-keys-dart-define-env-files/.

The `WeatherRepositorImpl` class implements the contract of the `WeatherRepository`. It has a `WeatherRemoteDataSource` passed in the constructor and calls its method. It uses try/catch to transform exceptions into `Failure` objects (Left side of Either) and the `WeatherModel` returned from sucessful calls into a `WeatherEntity` (Right side of Either). 

### Common objects and functions

`Failure` is an abstract class, to be extended by concrete Failures, e.g. `ServerFailure`
`ServerException` can be thrown in `WeatherRemoteDataSource`. 

### main.dart

In `main.dart`, we insert a `ChangeNotifierProvider` from the provider package and instantiate the classes down the dependeny chain: `WeatherNotifier`, `GetWeatherUsecase`, `WeatherRepositoryImpl`.

## Tests

The annotation "TDD" below indicates which classes are tested via Test-Driven Development. You can also write code first and tests later, whatever you prefer. 

`get_weather_usecase_test.dart` tests whether the (mocked) `WeatherRemoteDataSource` is called and whether `Right(WeatherEntity)` and `Left(ServerFailure)` are returned from the use case.

`weather_model_test.dart` tests whether the `WeatherModel` is a subclass of `WeatherEntity` and whether the model returned from its JSON factory constructor is assembled correctly.

`remote_datasource_test.dart` tests whether the `WeatherRemoteDataSource` retuns a `WeatherModel` if the API call is successful and throws a `ServerException` otherwise. The `http.Client` is mocked.

`weather_repository_impl_test.dart` tests whether the `WeatherRepositoryImpl` retuns a `Right(WeatherEntity)` from a `WeatherModel` passed in by the `WeatherRemoteDataSource` and otherwise turns a `ServerException` into a `Left(ServerFailure)` and a `SocketException` into a `Left(SocketFailure)`. The `WeatherRemoteDataSource` is mocked.

`weather_notifier_test.dart` tests the state management: is `WeatherNotifier` calling the (mocked) `GetWeatherUsecase`? Are listeners notified? Are the fields updated with a `WeatherEntity` or with a `Failure`? 

`weather_screen_test.dart` consists of widget tests. To get the test green that checks if the weather info appears on the screen, it is necessary to mock/stub/spy `WeatherNotifier`, which is a `ChangeNotifier` that updates the widget tree via the `Consumer` widget. This part is a bit tedious and [not well documented](https://github.com/rrousselGit/provider/issues/182).    

Finally, folder `integration_test` has an integration test. It is run with

`flutter test integration_test --dart-define OWM_API_KEY=<API KEY>`

Pure data classes, abstract classes and the third party dependencies are not tested. The ui layer has both unit tests for the `WeatherNotifier` state management class and widget tests for the `WeatherScreen`. The `test/utils` folder contains dummy JSON data that we need in more than one test and a reader helper function.

I am using the [mocktail](https://pub.dev/packages/mocktail) package for mocking dependencies.

## Order of implementation 

Implement the Domain Layer

1. WeatherEntity
2. WeatherRepository
3. Failure
4. GetWeatherUsecase (TDD) (alternatively start from here)

Implement the Data Layer

5. WeatherModel (TDD)
6. WeatherRemoteDataSource (TDD)
7. ServerException, Urls
8. WeatherRepositoryImpl (TDD)
9. ServerFailure, ConnectionFailure

Implement the UI Layer

10. WeatherNotifier (TDD)
11. main.dart / ChangeNotifierProvider  
12. WeatherScreen / Consumer (TDD)

### App Preparation 

To allow internet access, `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` have to have these entries:

```
<!-- Required to fetch data from the internet. -->
<key>com.apple.security.network.client</key>
<true/>
```

## Why minimal?

![diagram](docs/weather_app_tdd.png)

Clean architecture already is a handful. There are quite a few concepts to grasp and the reasons behind particular decisions are often not explained. There are abstractions and lots of directories. 

"All problems in computer science can be solved by another level of indirection, except for the problem of too many layers of indirection.", attributed to [David Wheeler](https://en.wikipedia.org/wiki/David_Wheeler_%28computer_scientist%29) illustrates the issue of having too much of abstraction. 

Therefore the goal for this example is to be as minimal as possible. I do not use injection containers, hooks, API wrappers, code generation or some of the other third party packages some authors of clean architecture tutorials are fond of. For state management, I follow the basic 'Provider' approach https://docs.flutter.dev/data-and-backend/state-mgmt/simple. I also use the [equatable](https://pub.dev/packages/equatable) package to simplify object comparison in tests a bit and the `Either` construct from the [fpdart library](https://pub.dev/packages/fpdart) in order to transform exceptions into types inside the repository.  

I decided to not write additional abstract superclasses of Use Cases to avoid subsequent modeling of the parameters which adds a lot of complexity and little benefit in my oponion. The same goes with the Data Sources which also could be further abstracted. Because tha app only has one feature - getting the current weather - I decided to leave out the "feature" directory and because the example is minimal, I put the all the files that belong to a leyer into one directory: "ui", "domain" and "data", and a "common" directory for items used besides or across the layers such as error types or constants used in code and in tests such as the URL of the API. 

Some of the terms used in the clean code approach have been adapted by different authors and there seems to be a bit of confusion about naming. As an example, the Flutter reactive state management is called "business logic" in some tutorials. Business logic, however is commonly understood as the things that happen in the Domain layer, e.g. the Use Cases of the application, not the mechanisms that implement reactivity. I also prefer the term "ui layer" over "presentation layer".     

For me, the benfit of clean architecture is that it provides a structure in which one knows where to look for certain parts and what to test. It is testable because dependencies are passed into classes via constructors. We can test layer by layer and mock out the layers that are depended on. It is possible to add, swap and remove elements of the architecture horizontally (user interface, databases, APIs) and vertically (features). It is likely that these benefits become only obvious after we would add more features to the app, but keeping this example minimal helps to understand the architecture. 

A few ideas for extending the example are:

* Support different temperature units
* Load the weather icon from the API (this is done from inside the ui in the tutorial source) 
* Enter the OpenWeather API key on startup, store it and offer a settings screen to change it  
* Store a list of favourite cities
* Support different languages
* Test on and adapt to different platforms (I developed for macOs)
* Better error handling, more fine grained Exception / Failure types 
* Handle loading state / long loading (this is done with Bloc the tutorial source)
* Expand the app functionality with other data from the OpenWeather API such as forecasts 
* Design a nice UI / weather animations
* Switch out the API with a different one as an exercise

## Resources 

This example is distilled from these sources:

* https://www.youtube.com/watch?v=g2Mup12MccU / https://betterprogramming.pub/flutter-clean-architecture-test-driven-development-practical-guide-445f388e8604 (main source)

* https://www.goodreads.com/book/show/18043011-clean-architecture
* https://www.goodreads.com/en/book/show/387190

* https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/
* https://codewithandrea.com/articles/comparison-flutter-app-architectures/ 
* https://codewithandrea.com/articles/flutter-api-keys-dart-define-env-files/
* https://stackoverflow.com/questions/51791501/how-to-debounce-textfield-onchange-in-dart

## License

MIT License


