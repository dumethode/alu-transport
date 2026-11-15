import 'package:alu_transport/features/settings/data/repositories/shared_prefs_settings_repository.dart';
import 'package:alu_transport/features/settings/domain/entities/app_settings.dart';
import 'package:alu_transport/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('starts with the default settings', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SettingsCubit cubit = SettingsCubit(
      SharedPrefsSettingsRepository(prefs),
    )..load();
    expect(cubit.state, const AppSettings());
    await cubit.close();
  });

  test('saves every preference and restores it after a restart', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SettingsCubit first = SettingsCubit(
      SharedPrefsSettingsRepository(prefs),
    )..load();
    await first.setTheme(ThemePreference.dark);
    await first.setUse24HourTime(false);
    await first.setShowAlertBanners(false);
    await first.setLargeText(true);
    await first.close();

    // A new cubit reading the same storage acts like the app reopening.
    final SettingsCubit reopened = SettingsCubit(
      SharedPrefsSettingsRepository(prefs),
    )..load();
    expect(
      reopened.state,
      const AppSettings(
        theme: ThemePreference.dark,
        use24HourTime: false,
        showAlertBanners: false,
        largeText: true,
      ),
    );
    await reopened.close();
  });
}
