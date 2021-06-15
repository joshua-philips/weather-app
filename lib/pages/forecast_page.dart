import 'package:flutter/material.dart';
import 'package:weather_app/components/navigation_bar.dart';

class ForecastPage extends StatelessWidget {
  final String location;
  final String currentWeather;
  final List<int> minTemperatureForecast;
  final List<int> maxTemperatureForecast;
  final List<String> abbreviationForecast;

  const ForecastPage(
      {Key key,
      this.location,
      this.minTemperatureForecast,
      this.maxTemperatureForecast,
      this.abbreviationForecast,
      this.currentWeather})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        page: 'explore',
      ),
    );
  }
}
