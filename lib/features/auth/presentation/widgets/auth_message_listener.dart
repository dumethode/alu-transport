import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Shows auth errors and success messages as snack bars, once each.
class AuthMessageListener extends StatelessWidget {
  const AuthMessageListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          current.errorMessage != previous.errorMessage ||
          current.infoMessage != previous.infoMessage,
      listener: (BuildContext context, AuthState state) {
        // Only the screen on top shows the message, so it never shows twice.
        final bool onTop = ModalRoute.of(context)?.isCurrent ?? true;
        final String? message = state.errorMessage ?? state.infoMessage;
        if (!onTop || message == null) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: state.errorMessage != null
                  ? AppColors.danger
                  : AppColors.primaryDark,
            ),
          );
        context.read<AuthCubit>().clearMessages();
      },
      child: child,
    );
  }
}
