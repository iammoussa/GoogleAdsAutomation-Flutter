import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

class ThemeState {
  final ThemeMode themeMode;
  final Brightness systemBrightness;

  ThemeState({
    required this.themeMode,
    this.systemBrightness = Brightness.light,
  });

  // Determine actual theme to use
  ThemeMode get effectiveThemeMode {
    if (themeMode == ThemeMode.system) {
      return systemBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    }
    return themeMode;
  }

  bool get isDark => effectiveThemeMode == ThemeMode.dark;

  ThemeState copyWith({
    ThemeMode? themeMode,
    Brightness? systemBrightness,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      systemBrightness: systemBrightness ?? this.systemBrightness,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _key = 'theme_mode';

  ThemeCubit() : super(ThemeState(themeMode: ThemeMode.system)) {
    _loadThemeMode();
  }

  // Load saved theme mode
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);

    if (savedMode != null) {
      final themeMode = _fromString(savedMode);
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  // Change theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(mode));
    emit(state.copyWith(themeMode: mode));
  }

  // Update system brightness (called when system changes)
  void updateSystemBrightness(Brightness brightness) {
    if (state.systemBrightness != brightness) {
      emit(state.copyWith(systemBrightness: brightness));
    }
  }

  // Convert to/from string for SharedPreferences
  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}