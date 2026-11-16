import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_message_listener.dart';
import '../widgets/password_field.dart';

/// Create an account with email and password.
/// Firebase then sends a verification email.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthCubit>().register(
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: AuthMessageListener(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 14,
                    children: <Widget>[
                      Text(
                        'Use your ALU email. We will send you a link to '
                        'confirm it is really you.',
                        style: TextStyle(color: context.mutedText),
                      ),
                      AppTextField(
                        label: 'Full name',
                        controller: _name,
                        hint: 'Jean Muhire',
                        icon: AppIcons.user,
                        textInputAction: TextInputAction.next,
                        validator: Validators.fullName,
                        autofillHints: const <String>[AutofillHints.name],
                      ),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        hint: 'name@alustudent.com',
                        icon: AppIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        autofillHints: const <String>[AutofillHints.email],
                      ),
                      PasswordField(
                        controller: _password,
                        validator: Validators.newPassword,
                        textInputAction: TextInputAction.next,
                      ),
                      PasswordField(
                        label: 'Confirm password',
                        controller: _confirm,
                        validator: (String? value) =>
                            Validators.confirmPassword(value, _password.text),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 4),
                      BlocSelector<AuthCubit, AuthState, bool>(
                        selector: (AuthState state) => state.isSubmitting,
                        builder: (BuildContext context, bool busy) {
                          return AppButton(
                            label: 'Create account',
                            isLoading: busy,
                            onPressed: _submit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
