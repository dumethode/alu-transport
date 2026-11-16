import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_message_listener.dart';

/// Sends a Firebase password reset email.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthCubit>().sendPasswordReset(_email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: AuthMessageListener(
        child: Form(
          key: _formKey,
          child: ResponsiveBody(
            spacing: 16,
            children: <Widget>[
              Text(
                'Enter the email you signed up with. We will send you a link '
                'to choose a new password.',
                style: TextStyle(color: context.mutedText, height: 1.4),
              ),
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'name@alustudent.com',
                icon: AppIcons.mail,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                onSubmitted: (_) => _submit(),
              ),
              BlocSelector<AuthCubit, AuthState, bool>(
                selector: (AuthState state) => state.isSubmitting,
                builder: (BuildContext context, bool busy) {
                  return AppButton(
                    label: 'Send reset link',
                    icon: AppIcons.send,
                    isLoading: busy,
                    onPressed: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
