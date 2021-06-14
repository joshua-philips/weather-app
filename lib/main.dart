import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/components/forecast_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temperature;
  String location = 'Lagos';

  /// Where on Earth Id. Special api element used to describe location
  int woeid = 1398823;
  String weather = 'clear';

  /// Two/Three letter decription of weather by MetaWeather, usually used to get weather image
  String abbreviation = '';
  String errorMessage = '';

  // Forecast elements
  List<int> minTemperatureForecast = [];
  List<int> maxTemperatureForecast = [];
  List<String> abbreviationForecast = [];

  @override
  void initState() {
    super.initState();
    fetchLocation();
    fetchLocationDay();
  }

  Future<void> fetchSearch(String input) async {
    try {
      Uri searchApiUrl = Uri.parse(
          'https://www.metaweather.com/api/location/search/?query=$input');
      http.Response searchResult = await http.get(searchApiUrl);
      Map result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = "We don't have data about this place.";
      });
    }
  }

  Future<void> fetchLocation() async {
    Uri locationApiUrl = Uri.parse(
        'https://www.metaweather.com/api/location/${woeid.toString()}');
    http.Response locationResult = await http.get(locationApiUrl);
    Map result = json.decode(locationResult.body);
    List consolidatedWeather = result["consolidated_weather"];
    Map data = consolidatedWeather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  Future<void> fetchLocationDay() async {
    minTemperatureForecast.clear();
    maxTemperatureForecast.clear();
    abbreviationForecast.clear();

    for (int i = 0; i < 7; i++) {
      Uri locationDayApiUrl = Uri.parse(
          "https://www.metaweather.com/api/location/${woeid.toString()}" +
              "/${DateFormat('y/M/d').format(DateTime.now().add(Duration(days: i + 1))).toString()}");
      http.Response locationDayResult = await http.get(locationDayApiUrl);
      List result = json.decode(locationDayResult.body);
      Map data = result[0];

      setState(() {
        minTemperatureForecast.add(data["min_temp"].round());
        maxTemperatureForecast.add(data["max_temp"].round());
        abbreviationForecast.add(data["weather_state_abbr"]);
      });
    }
  }

  Future<void> onSubmitted(String input) async {
    setState(() {
      errorMessage = '';
    });
    await fetchSearch(input);
    await fetchLocation();
    await fetchLocationDay();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.dstATop),
            fit: BoxFit.cover,
          ),
        ),
        child: temperature == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () async {
                          // Position from geolocator
                          Position position = await _determinePosition();
                          // Using geocoding to get place name
                          placemarkFromCoordinates(
                                  position.latitude, position.longitude)
                              .then((placemarks) {
                            if (placemarks.isNotEmpty) {
                              print(placemarks[0].toJson());
                              onSubmitted(placemarks[0].locality);
                            } else {
                              print('placemarks is empty');
                            }
                          });
                        },
                        child: Icon(Icons.location_on, size: 36.0),
                      ),
                    ),
                  ],
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                body: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: [
                          Center(
                            child: Image.network(
                              'https://www.metaweather.com/static/img/weather/png/' +
                                  abbreviation +
                                  '.png',
                              width: 80,
                            ),
                          ),
                          Center(
                            child: Text(
                              temperature.toString() + '°C',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 40.0),
                            ),
                          ),
                          Center(
                            child: Text(
                              location,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 40.0),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            for (var i = 0;
                                i < minTemperatureForecast.length;
                                i++)
                              ForecastCard(
                                daysFromNow: i + 1,
                                abbreviation: abbreviationForecast[i],
                                minTemperature: minTemperatureForecast[i],
                                maxTemperature: maxTemperatureForecast[i],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Container(
                            width: 300,
                            child: TextField(
                              onSubmitted: (String input) {
                                onSubmitted(input);
                              },
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                              decoration: InputDecoration(
                                hintText: 'Search location...',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              right: 32.0,
                              left: 32.0,
                            ),
                            child: Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
