import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Password input with a show/hide button.
/// The hidden flag lives in a [ValueNotifier], so no setState is needed.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.validator,
    this.label = 'Password',
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final String label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final ValueNotifier<bool> _hidden = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _hidden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _hidden,
      builder: (BuildContext context, bool hidden, Widget? child) {
        return AppTextField(
          label: widget.label,
          controller: widget.controller,
          hint: '••••••••',
          icon: AppIcons.lock,
          obscureText: hidden,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          autofillHints: const <String>[AutofillHints.password],
          suffix: IconButton(
            tooltip: hidden ? 'Show password' : 'Hide password',
            onPressed: () => _hidden.value = !hidden,
            icon: AppIcon(
              hidden ? AppIcons.eye : AppIcons.eyeOff,
              size: 20,
              color: context.mutedText,
            ),
          ),
        );
      },
    );
  }
}
