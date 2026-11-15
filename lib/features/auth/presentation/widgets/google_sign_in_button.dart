import 'package:flutter/material.dart';

import '../../../../core/widgets/app_icon.dart';

/// Outlined "Continue with Google" button with the Google logo.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            GoogleLogo(),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Continue with Google',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
