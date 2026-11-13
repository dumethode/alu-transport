import 'package:equatable/equatable.dart';

/// Theme choice saved on the phone.
enum ThemePreference { system, light, dark }

/// User preferences kept with SharedPreferences.
/// All four are saved on change and restored when the app restarts.
class AppSettings extends Equatable {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.use24HourTime = true,
    this.showAlertBanners = true,
    this.largeText = false,
  });

  final ThemePreference theme;
  final bool use24HourTime;
  final bool showAlertBanners;
  final bool largeText;

  AppSettings copyWith({
    ThemePreference? theme,
    bool? use24HourTime,
    bool? showAlertBanners,
    bool? largeText,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      use24HourTime: use24HourTime ?? this.use24HourTime,
      showAlertBanners: showAlertBanners ?? this.showAlertBanners,
      largeText: largeText ?? this.largeText,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    theme,
    use24HourTime,
    showAlertBanners,
    largeText,
  ];
}
