import 'package:flutter/material.dart';
import 'package:weather_app/components/forecast_card.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int temperature;
  String location = 'Lagos';

  /// Where on Earth Id. Special api element used to describe location
  int woeid = 1398823;
  String weather = 'clear';

  /// One/Two letter decription of weather by MetaWeather, usually used to get weather image
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

    for (int i = 0; i < 8; i++) {
      Uri locationDayApiUrl = Uri.parse(
          "https://www.metaweather.com/api/location/${woeid.toString()}" +
              "/${DateFormat('y/M/d').format(DateTime.now().add(Duration(days: i))).toString()}");
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () async {
                // Position from geolocator
                Position position = await _determinePosition();
                // Using geocoding to get place name
                placemarkFromCoordinates(position.latitude, position.longitude)
                    .then((placemarks) {
                  if (placemarks.isNotEmpty) {
                    print(placemarks[0].toJson());
                    onSubmitted(placemarks[0].locality);
                  } else {
                    print('placemarks is empty');
                  }
                });
              },
              child: Icon(
                Icons.location_on,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: abbreviationForecast.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Loading data...',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/world_map.png'),
                      colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.3),
                          BlendMode.dstATop),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                CircularProgressIndicator(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  location,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/world_map.png'),
                      colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.3),
                          BlendMode.dstATop),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.metaweather.com/static/img/weather/png/' +
                            abbreviation +
                            '.png',
                        width: 100,
                      ),
                      Text(
                        temperature.toString() + '°C',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      Text(
                        weather[0].toUpperCase() +
                            weather.substring(1, weather.length),
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 30),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                TodayCard(
                  abbreviation: abbreviation,
                  daysFromNow: 0,
                  maxTemperature: maxTemperatureForecast[0],
                  minTemperature: minTemperatureForecast[0],
                ),
              ],
            ),
    );
  }
}
