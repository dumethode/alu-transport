import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_message_listener.dart';

/// Shown after registering until the user opens the verification link.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthMessageListener(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) {
            final AuthCubit cubit = context.read<AuthCubit>();
            return ResponsiveBody(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              spacing: 14,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: AppIcon(
                      AppIcons.mail,
                      size: 34,
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const Text(
                  'Check your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'We sent a verification link to ${state.user?.email ?? 'your email'}. '
                  'Open it, then come back and tap the button below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.mutedText, height: 1.4),
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'I have verified my email',
                  icon: AppIcons.checkCircle,
                  isLoading: state.isSubmitting,
                  onPressed: cubit.checkVerified,
                ),
                AppButton(
                  label: 'Send the email again',
                  icon: AppIcons.refresh,
                  variant: AppButtonVariant.outline,
                  onPressed: state.isSubmitting
                      ? null
                      : cubit.resendVerification,
                ),
                TextButton(
                  onPressed: cubit.signOut,
                  child: const Text('Use a different account'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
