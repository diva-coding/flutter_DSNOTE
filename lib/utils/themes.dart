import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;
  final SharedPreferences _preferences;

  ThemeProvider(this._preferences) {
    _isDarkTheme = _preferences.getBool('isDarkTheme') ?? false;
  }

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await _preferences.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  // ...other theme properties
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.indigo,
  scaffoldBackgroundColor: Colors.black,
  // ...other theme properties
);
