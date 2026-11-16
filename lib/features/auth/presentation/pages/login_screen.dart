import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_message_listener.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_field.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Figma screen 1: welcome and log in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthCubit>().signIn(
      email: _email.text,
      password: _password.text,
    );
  }

  void _open(Widget screen) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (BuildContext context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthMessageListener(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const AuthHeader(
                title: 'ALU Transport',
                subtitle: 'Know where your bus is. No guessing.',
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AppTextField(
                              label: 'Student / staff email',
                              controller: _email,
                              hint: 'name@alustudent.com',
                              icon: AppIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.email,
                              autofillHints: const <String>[
                                AutofillHints.email,
                              ],
                            ),
                            const SizedBox(height: 14),
                            PasswordField(
                              controller: _password,
                              validator: Validators.loginPassword,
                              onSubmitted: (_) => _submit(),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _open(const ForgotPasswordScreen()),
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            BlocSelector<AuthCubit, AuthState, bool>(
                              selector: (AuthState state) => state.isSubmitting,
                              builder: (BuildContext context, bool busy) {
                                return Column(
                                  children: <Widget>[
                                    AppButton(
                                      label: 'Log in',
                                      isLoading: busy,
                                      onPressed: _submit,
                                    ),
                                    const _OrDivider(),
                                    GoogleSignInButton(
                                      isLoading: busy,
                                      onPressed: () => context
                                          .read<AuthCubit>()
                                          .signInWithGoogle(),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Text(
                                  'New here?',
                                  style: TextStyle(color: context.mutedText),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _open(const RegisterScreen()),
                                  child: const Text('Sign up'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: TextStyle(color: context.mutedText)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
