import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/components/navigation_bar.dart';

class ForecastPage extends StatelessWidget {
  final String location;
  final List<int> minTemperatureForecast;
  final List<int> maxTemperatureForecast;
  final List<String> abbreviationForecast;
  final List<String> weatherForecast;

  const ForecastPage(
      {Key key,
      this.location,
      this.minTemperatureForecast,
      this.maxTemperatureForecast,
      this.abbreviationForecast,
      this.weatherForecast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        page: 'explore',
      ),
      extendBody: true,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            centerTitle: true,
            floating: true,
            elevation: 0,
            title: Text(
              'Forecast',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              buildHeader(context),
              buildListTile(context),
              SizedBox(height: 60),
            ]),
          ),
        ],
      ),
    );
  }

  Container buildHeader(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 240,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/world_map.png'),
          colorFilter: ColorFilter.mode(
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
              BlendMode.dstATop),
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://www.metaweather.com/static/img/weather/png/' +
                abbreviationForecast[0] +
                '.png',
            width: 90,
          ),
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$location today',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  Text(
                    minTemperatureForecast[0].toString(),
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '/' + maxTemperatureForecast[0].toString() + '°C',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  )
                ],
              ),
              Text(
                weatherForecast[0],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildListTile(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(
      Column(
        children: [
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Colors.white,
              borderRadius: BorderRadius.circular(80),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
    for (int count = 1; count < minTemperatureForecast.length; count++) {
      widgetList.add(
        ListTile(
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                DateFormat.E()
                    .format(DateTime.now().add(Duration(days: count))),
                style: TextStyle(fontSize: 18),
              ),
              Spacer(),
              Image.network(
                'https://www.metaweather.com/static/img/weather/png/' +
                    abbreviationForecast[count] +
                    '.png',
                width: 30,
              ),
              SizedBox(width: 5),
              Text(
                weatherForecast[count],
                style: TextStyle(fontSize: 18),
              ),
              Spacer(),
              Text(
                minTemperatureForecast[count].toString() +
                    '/' +
                    maxTemperatureForecast[count].toString(),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
        child: Column(
          children: widgetList,
        ),
      ),
    );
  }
}
