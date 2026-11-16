import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/navigation/shell_tab_cubit.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';

/// Reacts to sign in and sign out (auth version).
/// It closes pushed screens so the gate below is always visible.
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
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.status != current.status ||
          previous.user?.uid != current.user?.uid,
      listener: (BuildContext context, AuthState state) {
        navigatorKey.currentState?.popUntil(
          (Route<dynamic> route) => route.isFirst,
        );
        context.read<ShellTabCubit>().reset();
      },
      child: child,
    );
  }
}
