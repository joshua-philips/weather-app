import 'package:flutter/material.dart';
import 'package:weather_app/pages/home__page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
