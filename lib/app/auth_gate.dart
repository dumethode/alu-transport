import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/widgets/app_icon.dart';
import '../core/widgets/state_views.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/verify_email_screen.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/profile/presentation/cubit/profile_state.dart';
import '../features/profile/presentation/pages/setup_screen.dart';
import 'shell/driver_shell.dart';
import 'shell/student_shell.dart';
import 'splash_screen.dart';

/// Chooses the first screen from the auth and profile state. Because the
/// screen is picked from state (not pushed), the back button can never
/// return to the login screen after signing in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (AuthState previous, AuthState current) =>
          previous.status != current.status,
      builder: (BuildContext context, AuthState auth) {
        switch (auth.status) {
          case AuthStatus.unknown:
            return const SplashScreen();
          case AuthStatus.signedOut:
            return const LoginScreen();
          case AuthStatus.needsVerification:
            return const VerifyEmailScreen();
          case AuthStatus.signedIn:
            return const _ProfileGate();
        }
      },
    );
  }
}

class _ProfileGate extends StatelessWidget {
  const _ProfileGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (ProfileState previous, ProfileState current) =>
          previous.status != current.status ||
          previous.profile?.role != current.profile?.role,
      builder: (BuildContext context, ProfileState state) {
        switch (state.status) {
          case ProfileStatus.initial:
          case ProfileStatus.loading:
            return const SplashScreen();
          case ProfileStatus.missing:
            return const SetupScreen();
          case ProfileStatus.failure:
            return Scaffold(
              body: Center(
                child: MessageView(
                  icon: AppIcons.alertTriangle,
                  title: 'Could not load your profile',
                  message:
                      'Check your internet connection, then sign in again.',
                  actionLabel: 'Sign out',
                  onAction: context.read<AuthCubit>().signOut,
                ),
              ),
            );
          case ProfileStatus.ready:
            return state.profile!.isDriver
                ? const DriverShell()
                : const StudentShell();
        }
      },
    );
  }
}
