import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/navigation/shell_tab_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/alerts/data/repositories/firestore_status_update_repository.dart';
import '../features/alerts/domain/repositories/status_update_repository.dart';
import '../features/alerts/presentation/cubit/alerts_cubit.dart';
import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/driver/presentation/cubit/driver_round_cubit.dart';
import '../features/profile/data/repositories/firestore_pickup_point_repository.dart';
import '../features/profile/data/repositories/firestore_profile_repository.dart';
import '../features/profile/domain/repositories/pickup_point_repository.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/presentation/cubit/pickup_points_cubit.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/requests/data/repositories/firestore_request_repository.dart';
import '../features/requests/domain/repositories/request_repository.dart';
import '../features/requests/presentation/cubit/driver_requests_cubit.dart';
import '../features/requests/presentation/cubit/student_request_cubit.dart';
import '../features/rounds/data/repositories/firestore_reminder_repository.dart';
import '../features/rounds/data/repositories/firestore_round_repository.dart';
import '../features/rounds/domain/repositories/reminder_repository.dart';
import '../features/rounds/domain/repositories/round_repository.dart';
import '../features/rounds/presentation/cubit/reminders_cubit.dart';
import '../features/rounds/presentation/cubit/rounds_cubit.dart';
import '../features/settings/data/repositories/shared_prefs_settings_repository.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import 'auth_gate.dart';
import 'session_listener.dart';

/// Lets the session listener close pushed screens on sign in and out.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Root widget. Repositories (data layer) are created once here and given
/// to the cubits (presentation layer) through dependency injection, so no
/// screen ever creates a repository itself.
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
        RepositoryProvider<ProfileRepository>(
          create: (BuildContext context) => FirestoreProfileRepository(),
        ),
        RepositoryProvider<PickupPointRepository>(
          create: (BuildContext context) => FirestorePickupPointRepository(),
        ),
        RepositoryProvider<RoundRepository>(
          create: (BuildContext context) => FirestoreRoundRepository(),
        ),
        RepositoryProvider<ReminderRepository>(
          create: (BuildContext context) => FirestoreReminderRepository(),
        ),
        RepositoryProvider<StatusUpdateRepository>(
          create: (BuildContext context) => FirestoreStatusUpdateRepository(),
        ),
        RepositoryProvider<RequestRepository>(
          create: (BuildContext context) => FirestoreRequestRepository(),
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
          BlocProvider<ProfileCubit>(
            create: (BuildContext context) =>
                ProfileCubit(context.read<ProfileRepository>()),
          ),
          BlocProvider<PickupPointsCubit>(
            create: (BuildContext context) =>
                PickupPointsCubit(context.read<PickupPointRepository>()),
          ),
          BlocProvider<RoundsCubit>(
            create: (BuildContext context) =>
                RoundsCubit(context.read<RoundRepository>()),
          ),
          BlocProvider<RemindersCubit>(
            create: (BuildContext context) =>
                RemindersCubit(context.read<ReminderRepository>()),
          ),
          BlocProvider<AlertsCubit>(
            create: (BuildContext context) =>
                AlertsCubit(context.read<StatusUpdateRepository>()),
          ),
          BlocProvider<StudentRequestCubit>(
            create: (BuildContext context) =>
                StudentRequestCubit(context.read<RequestRepository>()),
          ),
          BlocProvider<DriverRequestsCubit>(
            create: (BuildContext context) =>
                DriverRequestsCubit(context.read<RequestRepository>()),
          ),
          BlocProvider<DriverRoundCubit>(
            create: (BuildContext context) => DriverRoundCubit(
              rounds: context.read<RoundRepository>(),
              updates: context.read<StatusUpdateRepository>(),
            ),
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
