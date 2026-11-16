import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/widgets/app_button.dart';
import '../core/widgets/app_icon.dart';
import '../core/widgets/responsive_body.dart';
import '../core/widgets/state_views.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/verify_email_screen.dart';
import '../features/settings/presentation/pages/settings_screen.dart';
import 'splash_screen.dart';

/// Chooses the first screen from the auth state (auth version).
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
            return const _SignedInPlaceholder();
        }
      },
    );
  }
}

/// Temporary home until the profile feature is merged.
class _SignedInPlaceholder extends StatelessWidget {
  const _SignedInPlaceholder();

  @override
  Widget build(BuildContext context) {
    final String email = context.read<AuthCubit>().state.user?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('ALU Transport')),
      body: ResponsiveBody(
        children: <Widget>[
          MessageView(
            icon: AppIcons.checkCircle,
            title: 'You are signed in',
            message: 'Signed in as $email. Setup comes next.',
          ),
          AppButton(
            label: 'Open settings',
            icon: AppIcons.settings,
            variant: AppButtonVariant.outline,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const SettingsScreen(),
              ),
            ),
          ),
          AppButton(
            label: 'Sign out',
            icon: AppIcons.logOut,
            variant: AppButtonVariant.danger,
            onPressed: context.read<AuthCubit>().signOut,
          ),
        ],
      ),
    );
  }
}
