import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Every icon in the app. They are SVG line icons (Lucide, ISC licence),
/// drawn with [AppIcon] so the app never shows emojis.
enum AppIcons {
  alertTriangle,
  arrowLeft,
  bell,
  bus,
  checkCircle,
  chevronRight,
  clock,
  eye,
  eyeOff,
  home,
  info,
  list,
  lock,
  logOut,
  mail,
  map,
  mapPin,
  messageCircle,
  minus,
  moon,
  pencil,
  plus,
  refresh,
  route,
  send,
  settings,
  shuffle,
  sun,
  trash,
  user,
  users,
  x,
}

/// Draws one of the [AppIcons] in the current icon colour.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 22, this.color});

  final AppIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;

    return SvgPicture.string(
      _wrap(_paths(icon)),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }

  static String _wrap(String inner) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
      'fill="none" stroke="#000000" stroke-width="2" '
      'stroke-linecap="round" stroke-linejoin="round">$inner</svg>';

  static String _paths(AppIcons icon) {
    switch (icon) {
      case AppIcons.alertTriangle:
        return '<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/><path d="M12 9v4"/><path d="M12 17h.01"/>';
      case AppIcons.arrowLeft:
        return '<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>';
      case AppIcons.bell:
        return '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>';
      case AppIcons.bus:
        return '<path d="M8 6v6"/><path d="M15 6v6"/><path d="M2 12h19.6"/><path d="M18 18h3s.5-1.7.8-2.8c.1-.4.2-.8.2-1.2 0-4-1-8-2-1.2l-1.4-5C20.1 6.8 19.1 6 18 6H4a2 2 0 0 0-2 2v10h3"/><circle cx="7" cy="18" r="2"/><path d="M9 18h5"/><circle cx="16" cy="18" r="2"/>';
      case AppIcons.checkCircle:
        return '<circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/>';
      case AppIcons.chevronRight:
        return '<path d="m9 18 6-6-6-6"/>';
      case AppIcons.clock:
        return '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
      case AppIcons.eye:
        return '<path d="M2.06 12.35a11 11 0 0 1 0-.7 10.75 10.75 0 0 1 19.88 0 11 11 0 0 1 0 .7 10.75 10.75 0 0 1-19.88 0"/><circle cx="12" cy="12" r="3"/>';
      case AppIcons.eyeOff:
        return '<path d="M10.73 5.08A10.74 10.74 0 0 1 12 5a10.75 10.75 0 0 1 9.94 6.57 1 1 0 0 1 0 .7 10.75 10.75 0 0 1-1.44 2.49"/><path d="M14.08 14.16a3 3 0 0 1-4.24-4.24"/><path d="M17.48 17.5A10.75 10.75 0 0 1 1.94 12a1 1 0 0 1 0-.7 10.75 10.75 0 0 1 4.45-5.14"/><path d="m2 2 20 20"/>';
      case AppIcons.home:
        return '<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .71-1.53l7-6a2 2 0 0 1 2.58 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>';
      case AppIcons.info:
        return '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/>';
      case AppIcons.list:
        return '<path d="M3 12h.01"/><path d="M3 18h.01"/><path d="M3 6h.01"/><path d="M8 12h13"/><path d="M8 18h13"/><path d="M8 6h13"/>';
      case AppIcons.lock:
        return '<rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>';
      case AppIcons.logOut:
        return '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" x2="9" y1="12" y2="12"/>';
      case AppIcons.mail:
        return '<rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>';
      case AppIcons.map:
        return '<path d="M14.11 5.55a2 2 0 0 0 1.79 0l3.66-1.83A1 1 0 0 1 21 4.62v12.76a1 1 0 0 1-.55.9l-4.56 2.27a2 2 0 0 1-1.79 0l-4.2-2.1a2 2 0 0 0-1.8 0l-3.65 1.83A1 1 0 0 1 3 19.38V6.62a1 1 0 0 1 .55-.9l4.56-2.27a2 2 0 0 1 1.79 0z"/><path d="M15 5.76v15"/><path d="M9 3.24v15"/>';
      case AppIcons.mapPin:
        return '<path d="M20 10c0 5-5.54 10.19-7.4 11.8a1 1 0 0 1-1.2 0C9.54 20.19 4 15 4 10a8 8 0 0 1 16 0"/><circle cx="12" cy="10" r="3"/>';
      case AppIcons.messageCircle:
        return '<path d="M7.9 20A9 9 0 1 0 4 16.1L2 22z"/>';
      case AppIcons.minus:
        return '<path d="M5 12h14"/>';
      case AppIcons.moon:
        return '<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>';
      case AppIcons.pencil:
        return '<path d="M21.17 6.81a1 1 0 0 0-3.98-3.98L3.84 16.17a2 2 0 0 0-.5.83l-1.32 4.35a.5.5 0 0 0 .62.62l4.35-1.32a2 2 0 0 0 .83-.5z"/><path d="m15 5 4 4"/>';
      case AppIcons.plus:
        return '<path d="M5 12h14"/><path d="M12 5v14"/>';
      case AppIcons.refresh:
        return '<path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/>';
      case AppIcons.route:
        return '<circle cx="6" cy="19" r="3"/><path d="M9 19h8.5a3.5 3.5 0 0 0 0-7h-11a3.5 3.5 0 0 1 0-7H15"/><circle cx="18" cy="5" r="3"/>';
      case AppIcons.send:
        return '<path d="M14.54 21.69a.5.5 0 0 0 .94-.03l6.5-19a.5.5 0 0 0-.64-.63l-19 6.5a.5.5 0 0 0-.02.93l7.93 3.18a2 2 0 0 1 1.11 1.11z"/><path d="m21.85 2.15-10.94 10.94"/>';
      case AppIcons.settings:
        return '<line x1="21" x2="14" y1="4" y2="4"/><line x1="10" x2="3" y1="4" y2="4"/><line x1="21" x2="12" y1="12" y2="12"/><line x1="8" x2="3" y1="12" y2="12"/><line x1="21" x2="16" y1="20" y2="20"/><line x1="12" x2="3" y1="20" y2="20"/><line x1="14" x2="14" y1="2" y2="6"/><line x1="8" x2="8" y1="10" y2="14"/><line x1="16" x2="16" y1="18" y2="22"/>';
      case AppIcons.shuffle:
        return '<path d="m18 14 4 4-4 4"/><path d="m18 2 4 4-4 4"/><path d="M2 18h2a4 4 0 0 0 3.3-1.7l5.4-8.6a4 4 0 0 1 3.3-1.7H22"/><path d="M2 6h2a4 4 0 0 1 3.6 2.2"/><path d="M22 18h-6a4 4 0 0 1-3.3-1.8l-.36-.45"/>';
      case AppIcons.sun:
        return '<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>';
      case AppIcons.trash:
        return '<path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/>';
      case AppIcons.user:
        return '<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>';
      case AppIcons.users:
        return '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>';
      case AppIcons.x:
        return '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>';
    }
  }
}

/// The full-colour Google "G" used on the Google sign-in button.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});
  final double size;

  static const String _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<path fill="#FFC107" d="M43.6 20.1H42V20H24v8h11.3c-1.6 4.7-6.1 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 8 3l5.7-5.7C34 6.1 29.3 4 24 4 13 4 4 13 4 24s9 20 20 20 20-9 20-20c0-1.3-.1-2.6-.4-3.9z"/>'
      '<path fill="#FF3D00" d="m6.3 14.7 6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 8 3l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z"/>'
      '<path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2A11.9 11.9 0 0 1 24 36c-5.2 0-9.6-3.3-11.3-7.9l-6.5 5C9.5 39.6 16.2 44 24 44z"/>'
      '<path fill="#1976D2" d="M43.6 20.1H42V20H24v8h11.3a12 12 0 0 1-4.1 5.6l6.2 5.2C41.4 35.2 44 30 44 24c0-1.3-.1-2.6-.4-3.9z"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
