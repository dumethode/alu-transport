import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_icon.dart';

/// The three button looks used in the Figma file.
enum AppButtonVariant { primary, outline, danger }

/// A full-width button with an optional SVG icon and a loading state.
/// Height is 48dp so it meets the Material minimum tap size.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppIcons? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = isLoading ? null : onPressed;
    final Widget content = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                AppIcon(icon!, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(onPressed: action, child: content);
      case AppButtonVariant.danger:
        button = FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          onPressed: action,
          child: content,
        );
      case AppButtonVariant.outline:
        button = OutlinedButton(onPressed: action, child: content);
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
