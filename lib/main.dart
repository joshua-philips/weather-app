import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  int woeid = 1398823;
  String weather = 'clear';
  String abbreviation = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  Future<void> fetchSearch(String input) async {
    try {
      Uri searchApiUrl = Uri.parse(
          'https://www.metaweather.com/api/location/search/?query=$input');
      var searchResult = await http.get(searchApiUrl);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = "We don't have data about this city. Try another one.";
      });
    }
  }

  Future<void> fetchLocation() async {
    var locationApiUrl = Uri.parse(
        'https://www.metaweather.com/api/location/${woeid.toString()}');
    var locationResult = await http.get(locationApiUrl);
    var result = json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  Future<void> onTextFieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: temperature == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/' +
                                abbreviation +
                                '.png',
                            width: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            temperature.toString() + ' °C',
                            style:
                                TextStyle(color: Colors.white, fontSize: 60.0),
                          ),
                        ),
                        Center(
                          child: Text(
                            location,
                            style:
                                TextStyle(color: Colors.white, fontSize: 40.0),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextFieldSubmitted(input);
                            },
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            decoration: InputDecoration(
                              hintText: 'Search another location...',
                              hintStyle: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 32.0, left: 32.0),
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
    );
  }
}
