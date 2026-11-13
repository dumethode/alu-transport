import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Outlined input style from the Figma file, shared by every form.
InputDecoration appInputDecoration(
  BuildContext context, {
  String? hint,
  AppIcons? icon,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: context.colors.surface,
    prefixIcon: icon == null
        ? null
        : Padding(
            padding: const EdgeInsets.all(12),
            child: AppIcon(icon, size: 20, color: context.mutedText),
          ),
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(context.colors.outline),
    enabledBorder: border(context.colors.outline),
    focusedBorder: border(context.colors.primary, 1.5),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.5),
  );
}

/// A label above an outlined [TextFormField], with the error shown below.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final AppIcons? icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: context.mutedText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          onFieldSubmitted: onSubmitted,
          autofillHints: autofillHints,
          decoration: appInputDecoration(
            context,
            hint: hint,
            icon: icon,
            suffix: suffix,
          ),
        ),
      ],
    );
  }
}
