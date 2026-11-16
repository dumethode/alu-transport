import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/navigation/shell_tab_cubit.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/profile/domain/entities/user_profile.dart';
import '../features/profile/presentation/cubit/pickup_points_cubit.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/profile/presentation/cubit/profile_state.dart';

/// Starts and stops the profile streams on sign in and sign out
/// (profile version).
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
    navigatorKey.currentState?.popUntil(
      (Route<dynamic> route) => route.isFirst,
    );
    final String? uid = state.user?.uid;
    if (state.status == AuthStatus.signedIn && uid != null) {
      context.read<ProfileCubit>().watch(uid);
      context.read<PickupPointsCubit>().watch();
    } else {
      context.read<ShellTabCubit>().reset();
      context.read<ProfileCubit>().reset();
      context.read<PickupPointsCubit>().reset();
    }
  }

  void _onProfileChanged(BuildContext context, ProfileState state) {
    final UserProfile? profile = state.profile;
    if (state.status != ProfileStatus.ready || profile == null) {
      return;
    }
    context.read<ShellTabCubit>().reset();
    if (profile.isDriver) {
      context.read<PickupPointsCubit>().seedIfEmpty();
    }
  }
}
