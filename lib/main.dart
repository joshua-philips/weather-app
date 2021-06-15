import 'package:flutter/material.dart';
import 'package:weather_app/pages/home__page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

// TextField(
// onSubmitted: (String input) {
// onSubmitted(input);
//},
//style:
//TextStyle(color: Colors.white, fontSize: 25),
//decoration: InputDecoration(
// hintText: 'Search location...',
//hintStyle: TextStyle(
// color: Colors.white, fontSize: 18.0),
//prefixIcon:
//Icon(Icons.search, color: Colors.white),
//),
//),
