import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
  );

  static final _darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown, brightness: Brightness.dark),
  );

  void updateTheme(bool isDarkMode) {
    emit(isDarkMode ? _darkTheme : _lightTheme);
  }
}
