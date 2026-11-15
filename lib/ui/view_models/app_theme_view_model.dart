import 'package:flutter/material.dart';

enum AppAppearance { light, dark, system, christmas }

class AppThemeViewModel extends ChangeNotifier {
  AppAppearance _appearance = AppAppearance.light;
  Locale _locale = const Locale('en');

  AppAppearance get appearance => _appearance;
  ThemeMode get themeMode => switch (_appearance) {
    AppAppearance.light || AppAppearance.christmas => ThemeMode.light,
    AppAppearance.dark => ThemeMode.dark,
    AppAppearance.system => ThemeMode.system,
  };
  Locale get locale => _locale;

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isRTL => _locale.languageCode == 'ar';

  void setThemeMode(ThemeMode mode) {
    setAppearance(switch (mode) {
      ThemeMode.light => AppAppearance.light,
      ThemeMode.dark => AppAppearance.dark,
      ThemeMode.system => AppAppearance.system,
    });
  }

  void setAppearance(AppAppearance mode) {
    _appearance = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _appearance = _appearance == AppAppearance.light
        ? AppAppearance.dark
        : AppAppearance.light;
    notifyListeners();
  }

  void setLocale(Locale loc) {
    _locale = loc;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    notifyListeners();
  }
}
