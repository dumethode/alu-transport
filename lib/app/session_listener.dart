import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/navigation/shell_tab_cubit.dart';
import '../features/alerts/presentation/cubit/alerts_cubit.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/driver/presentation/cubit/driver_round_cubit.dart';
import '../features/profile/domain/entities/user_profile.dart';
import '../features/profile/presentation/cubit/pickup_points_cubit.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/profile/presentation/cubit/profile_state.dart';
import '../features/requests/presentation/cubit/driver_requests_cubit.dart';
import '../features/requests/presentation/cubit/student_request_cubit.dart';
import '../features/rounds/presentation/cubit/reminders_cubit.dart';
import '../features/rounds/presentation/cubit/rounds_cubit.dart';

/// Starts and stops the data streams when the user signs in or out.
///
/// All cubits live above MaterialApp, so every pushed screen can read
/// them. This widget makes sure they follow the signed-in user, and that
/// sign out clears every stream and pops back to the first screen.
class SessionListener extends StatelessWidget {
  const SessionListener({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (AuthState previous, AuthState current) =>
              previous.status != current.status ||
              previous.user?.uid != current.user?.uid,
          listener: _onAuthChanged,
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (ProfileState previous, ProfileState current) =>
              previous.status != current.status ||
              previous.profile?.role != current.profile?.role,
          listener: _onProfileChanged,
        ),
      ],
      child: child,
    );
  }

  void _onAuthChanged(BuildContext context, AuthState state) {
    // Close pushed screens (register, settings...) so the gate is visible.
    navigatorKey.currentState?.popUntil(
      (Route<dynamic> route) => route.isFirst,
    );
    final String? uid = state.user?.uid;
    if (state.status == AuthStatus.signedIn && uid != null) {
      context.read<ProfileCubit>().watch(uid);
      context.read<PickupPointsCubit>().watch();
    } else {
      _stopEverything(context);
    }
  }

  void _onProfileChanged(BuildContext context, ProfileState state) {
    final UserProfile? profile = state.profile;
    if (state.status != ProfileStatus.ready || profile == null) {
      return;
    }
    context.read<ShellTabCubit>().reset();
    context.read<RoundsCubit>().watchToday();
    context.read<AlertsCubit>().watch();
    if (profile.isDriver) {
      context.read<PickupPointsCubit>().seedIfEmpty();
      context.read<DriverRoundCubit>().start(profile.uid);
      context.read<DriverRequestsCubit>().watch();
    } else {
      context.read<RemindersCubit>().watch(profile.uid);
      context.read<StudentRequestCubit>().watch(profile.uid);
    }
  }

  void _stopEverything(BuildContext context) {
    context.read<ShellTabCubit>().reset();
    context.read<ProfileCubit>().reset();
    context.read<PickupPointsCubit>().reset();
    context.read<RoundsCubit>().reset();
    context.read<AlertsCubit>().reset();
    context.read<RemindersCubit>().reset();
    context.read<StudentRequestCubit>().reset();
    context.read<DriverRequestsCubit>().reset();
    context.read<DriverRoundCubit>().reset();
  }
}
