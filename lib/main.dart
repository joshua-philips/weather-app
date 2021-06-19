import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/home__page.dart';
import 'package:weather_app/theme_notifier.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      builder: (context, child) => MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme:
            context.watch<ThemeNotifier>().darkTheme ? darkTheme : lightTheme,
        home: HomePage(),
      ),
    );
  }
}
