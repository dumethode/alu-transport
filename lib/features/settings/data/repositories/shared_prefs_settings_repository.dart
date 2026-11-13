import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Stores [AppSettings] with SharedPreferences, one key per preference.
class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String themeKey = 'settings.theme';
  static const String timeFormatKey = 'settings.use24HourTime';
  static const String alertBannersKey = 'settings.showAlertBanners';
  static const String largeTextKey = 'settings.largeText';

  @override
  AppSettings load() {
    final String? savedTheme = _prefs.getString(themeKey);
    final ThemePreference theme = ThemePreference.values.firstWhere(
      (ThemePreference value) => value.name == savedTheme,
      orElse: () => ThemePreference.system,
    );
    return AppSettings(
      theme: theme,
      use24HourTime: _prefs.getBool(timeFormatKey) ?? true,
      showAlertBanners: _prefs.getBool(alertBannersKey) ?? true,
      largeText: _prefs.getBool(largeTextKey) ?? false,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _prefs.setString(themeKey, settings.theme.name);
    await _prefs.setBool(timeFormatKey, settings.use24HourTime);
    await _prefs.setBool(alertBannersKey, settings.showAlertBanners);
    await _prefs.setBool(largeTextKey, settings.largeText);
  }
}
