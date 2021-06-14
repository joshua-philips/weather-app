import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastCard extends StatelessWidget {
  /// Aditional number of days to be added to current day
  final int daysFromNow;

  /// Two/Three letter decription of weather by MetaWeather, usually used to get weather image
  final String abbreviation;
  final int minTemperature;
  final int maxTemperature;
  const ForecastCard(
      {Key key,
      this.daysFromNow,
      this.abbreviation,
      this.minTemperature,
      this.maxTemperature})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime oneDayFromNow = DateTime.now().add(Duration(days: daysFromNow));
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(205, 212, 228, 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                DateFormat.E().format(oneDayFromNow),
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              Text(
                DateFormat.MMMd().format(oneDayFromNow),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Image.network(
                  'https://www.metaweather.com/static/img/weather/png/' +
                      abbreviation +
                      '.png',
                  width: 50,
                ),
              ),
              Text(
                'High: ' + maxTemperature.toString() + '°C',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              Text(
                'Low: ' + minTemperature.toString() + '°C',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
