import 'package:flutter/material.dart';
import 'package:weather_app/pages/forecast_page.dart';

class NavigationBar extends StatelessWidget {
  /// 'home', 'forecast', 'profile'
  final String page;
  final String location;
  final List<int> minTemperatureForecast;
  final List<int> maxTemperatureForecast;
  final List<String> abbreviationForecast;
  final List<String> weatherForecast;
  const NavigationBar(
      {Key key,
      @required this.page,
      this.location,
      this.minTemperatureForecast,
      this.maxTemperatureForecast,
      this.abbreviationForecast,
      this.weatherForecast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color activePageColor = Theme.of(context).iconTheme.color;
    Color inactivePageColor =
        Theme.of(context).iconTheme.color.withOpacity(0.5);
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black),
          ],
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_rounded,
                color: page == 'home' ? activePageColor : inactivePageColor,
              ),
              onPressed: () {
                if (page != 'home') {
                  Navigator.popUntil(
                      context, (route) => !Navigator.canPop(context));
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.explore_outlined,
                color: page == 'forecast' ? activePageColor : inactivePageColor,
              ),
              onPressed: () {
                if (page != 'forecast') {
                  Route route = PageRouteBuilder(
                    pageBuilder: (context, a1, a2) => ForecastPage(
                      location: location,
                      maxTemperatureForecast: maxTemperatureForecast,
                      minTemperatureForecast: minTemperatureForecast,
                      abbreviationForecast: abbreviationForecast,
                      weatherForecast: weatherForecast,
                    ),
                    transitionDuration: Duration(seconds: 0),
                  );
                  Navigator.of(context).push(route);
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: page == 'profile' ? activePageColor : inactivePageColor,
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
