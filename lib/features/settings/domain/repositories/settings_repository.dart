import '../entities/app_settings.dart';

/// Reads and writes the user's preferences on this phone.
abstract class SettingsRepository {
  AppSettings load();

  Future<void> save(AppSettings settings);
}
