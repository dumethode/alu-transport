import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Holds the current [AppSettings]. Every change is shown at once and then
/// saved, so it is restored after the app is closed and opened again.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(const AppSettings());

  final SettingsRepository _repository;

  void load() => emit(_repository.load());

  Future<void> setTheme(ThemePreference theme) =>
      _update(state.copyWith(theme: theme));

  Future<void> setUse24HourTime(bool value) =>
      _update(state.copyWith(use24HourTime: value));

  Future<void> setShowAlertBanners(bool value) =>
      _update(state.copyWith(showAlertBanners: value));

  Future<void> setLargeText(bool value) =>
      _update(state.copyWith(largeText: value));

  Future<void> _update(AppSettings next) async {
    emit(next);
    await _repository.save(next);
  }
}

/// Converts the saved preference into Flutter's [ThemeMode].
extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode {
    switch (this) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }
}
