import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/navigation/shell_tab_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/settings/data/repositories/shared_prefs_settings_repository.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import 'auth_gate.dart';
import 'session_listener.dart';

/// Lets the session listener close pushed screens on sign in and out.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Root widget (auth version). Profile and bus features are added next.
class AluTransportApp extends StatelessWidget {
  const AluTransportApp({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>(
          create: (BuildContext context) =>
              SharedPrefsSettingsRepository(preferences),
        ),
        RepositoryProvider<AuthRepository>(
          create: (BuildContext context) => FirebaseAuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            create: (BuildContext context) =>
                SettingsCubit(context.read<SettingsRepository>())..load(),
          ),
          BlocProvider<ShellTabCubit>(
            create: (BuildContext context) => ShellTabCubit(),
          ),
          BlocProvider<AuthCubit>(
            create: (BuildContext context) =>
                AuthCubit(context.read<AuthRepository>())..start(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          builder: (BuildContext context, AppSettings settings) {
            return MaterialApp(
              title: 'ALU Transport',
              debugShowCheckedModeBanner: false,
              navigatorKey: appNavigatorKey,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settings.theme.themeMode,
              builder: (BuildContext context, Widget? child) {
                final MediaQueryData media = MediaQuery.of(context);
                return MediaQuery(
                  data: settings.largeText
                      ? media.copyWith(
                          textScaler: const TextScaler.linear(1.15),
                        )
                      : media,
                  child: SessionListener(
                    navigatorKey: appNavigatorKey,
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
              home: const AuthGate(),
            );
          },
        ),
      ),
    );
  }
}
