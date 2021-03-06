import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/components/forecast_card.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/components/navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/theme_notifier.dart';

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
  List<String> weatherForecast = [];
  List<String> abbreviationForecast = [];

  TextEditingController controller = TextEditingController();

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

      location = result['title'];
      woeid = result['woeid'];
      errorMessage = '';
    } catch (e) {
      setState(() {
        errorMessage =
            "We don't have data about ${input.isNotEmpty ? input : 'your location'}";
      });
    }
  }

  Future<void> fetchLocation() async {
    Uri locationApiUrl = Uri.parse(
        'https://www.metaweather.com/api/location/${woeid.toString()}');
    http.Response locationResult = await http.get(locationApiUrl);
    Map result = json.decode(locationResult.body);
    List consolidatedWeather = result['consolidated_weather'];
    Map data = consolidatedWeather[0];

    setState(() {
      temperature = data['the_temp'].round();
      weather = data['weather_state_name'];
      abbreviation = data['weather_state_abbr'];
    });
  }

  /// Get forecast data from api (includes current day)
  Future<void> fetchLocationDay() async {
    minTemperatureForecast.clear();
    maxTemperatureForecast.clear();
    abbreviationForecast.clear();

    for (int i = 0; i < 8; i++) {
      Uri locationDayApiUrl = Uri.parse(
          'https://www.metaweather.com/api/location/${woeid.toString()}' +
              '/${DateFormat('y/M/d').format(DateTime.now().add(Duration(days: i))).toString()}');
      http.Response locationDayResult = await http.get(locationDayApiUrl);
      List result = json.decode(locationDayResult.body);
      Map data = result[0];

      setState(() {
        minTemperatureForecast.add(data['min_temp'].round());
        maxTemperatureForecast.add(data['max_temp'].round());
        weatherForecast.add(data['weather_state_name']);
        abbreviationForecast.add(data['weather_state_abbr']);
      });
    }
  }

  Future<void> onSubmitted(String input) async {
    setState(() {
      errorMessage = 'Loading...';
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: buildSearchTextField(context),
        actions: [
          GestureDetector(
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
              size: 35,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Consumer<ThemeNotifier>(
              builder: (context, notifier, child) => CupertinoSwitch(
                value: notifier.darkTheme,
                onChanged: (value) {
                  notifier.toggleTheme();
                },
                activeColor: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
      body: abbreviationForecast.isEmpty
          ? loading()
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Text(
                    location,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 35),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    decoration: mapDecorationImage(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.metaweather.com/static/img/weather/png/' +
                              abbreviation +
                              '.png',
                          width: 120,
                        ),
                        Text(
                          temperature.toString() + '??C',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35),
                        ),
                        Text(
                          weather,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  TodayCard(
                    abbreviation: abbreviation,
                    daysFromNow: 0,
                    maxTemperature: maxTemperatureForecast[0],
                    minTemperature: minTemperatureForecast[0],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      errorMessage.isNotEmpty && errorMessage != 'Loading...'
                          ? Icon(Icons.error_outline)
                          : Container(),
                      SizedBox(width: 5),
                      Text(errorMessage, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: abbreviationForecast.length > 5
          ? NavigationBar(
              page: 'home',
              location: location,
              abbreviationForecast: abbreviationForecast,
              maxTemperatureForecast: maxTemperatureForecast,
              minTemperatureForecast: minTemperatureForecast,
              weatherForecast: weatherForecast,
            )
          : null,
    );
  }

  Container buildSearchTextField(BuildContext context) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search location...',
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.only(top: 5),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                controller.clear();
              }
            },
          ),
        ),
        onSubmitted: (String input) {
          if (controller.text.isNotEmpty) {
            onSubmitted(input);
          }
        },
      ),
    );
  }

  Widget loading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Text(
          'Loading data...',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 35),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 250,
          decoration: mapDecorationImage(),
        ),
        CircularProgressIndicator(),
      ],
    );
  }

  BoxDecoration mapDecorationImage() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/world_map.png'),
        colorFilter: ColorFilter.mode(
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
            BlendMode.dstATop),
        fit: BoxFit.cover,
      ),
    );
  }
}
