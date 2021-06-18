import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final String key = 'theme';
  SharedPreferences _pref;
  bool _darkTheme;
  bool get darkTheme => _darkTheme;

  ThemeNotifier() {
    _initPrefs();
    _darkTheme = false;
    _loadFromPrefs();
  }

  _initPrefs() async {
    if (_pref == null) {
      _pref = await SharedPreferences.getInstance();
    }
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _pref.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _pref.setBool(key, _darkTheme);
  }

  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.grey,
  primaryColor: Colors.white,
  accentColor: Colors.grey,
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.latoTextTheme(),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    textTheme: GoogleFonts.latoTextTheme(),
  ),
  cardColor: Colors.grey[100],
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.grey,
  accentColor: Colors.grey[300],
  scaffoldBackgroundColor: Colors.grey[900],
  textTheme: GoogleFonts.latoTextTheme(
    TextTheme(
      bodyText1: TextStyle(color: Colors.white),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
  ),
  appBarTheme: AppBarTheme(
    brightness: Brightness.dark,
    textTheme: GoogleFonts.latoTextTheme(),
  ),
  cardColor: Colors.grey[850],
);
