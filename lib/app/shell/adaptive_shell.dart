import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/shell_tab_cubit.dart';
import '../../core/widgets/app_icon.dart';

/// One tab of a shell.
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final AppIcons icon;
  final Widget page;
}

/// Bottom navigation bar on phones in portrait. A side navigation rail
/// on wide screens and in landscape, so nothing overflows when rotated.
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({super.key, required this.destinations});

  final List<ShellDestination> destinations;

  static const double railBreakpoint = 640;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellTabCubit, int>(
      builder: (BuildContext context, int index) {
        final ShellTabCubit tabs = context.read<ShellTabCubit>();
        final int selected = index.clamp(0, destinations.length - 1).toInt();
        // IndexedStack keeps each tab alive, so scroll positions are kept.
        final Widget pages = IndexedStack(
          index: selected,
          children: <Widget>[
            for (final ShellDestination destination in destinations)
              destination.page,
          ],
        );
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth >= railBreakpoint) {
              return Scaffold(
                body: Row(
                  children: <Widget>[
                    SafeArea(
                      right: false,
                      child: NavigationRail(
                        selectedIndex: selected,
                        onDestinationSelected: tabs.select,
                        labelType: NavigationRailLabelType.all,
                        destinations: <NavigationRailDestination>[
                          for (final ShellDestination destination
                              in destinations)
                            NavigationRailDestination(
                              icon: AppIcon(destination.icon),
                              label: Text(destination.label),
                            ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: pages),
                  ],
                ),
              );
            }
            return Scaffold(
              body: pages,
              bottomNavigationBar: NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: tabs.select,
                destinations: <NavigationDestination>[
                  for (final ShellDestination destination in destinations)
                    NavigationDestination(
                      icon: AppIcon(destination.icon),
                      label: destination.label,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
