import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import 'app_icon.dart';

/// Round profile picture made from a generated DiceBear avatar.
///
/// The app never shows name initials. If the avatar cannot load (for
/// example offline), the SVG person icon underneath stays visible.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.seed, this.size = 48});

  final String seed;
  final double size;

  /// Public DiceBear URL for a seed. The same seed always gives the
  /// same avatar, so only the seed is stored in Firestore.
  static String urlFor(String seed) =>
      'https://api.dicebear.com/9.x/notionists/svg'
      '?seed=${Uri.encodeComponent(seed)}&backgroundColor=e7f5ef';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Profile avatar',
      image: true,
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(
                color: AppColors.primaryLight,
                child: Center(
                  child: AppIcon(
                    AppIcons.user,
                    size: size * 0.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SvgPicture.network(
                urlFor(seed),
                fit: BoxFit.cover,
                placeholderBuilder: (BuildContext context) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
