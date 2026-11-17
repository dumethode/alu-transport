import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/shell_tab_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../features/alerts/domain/entities/status_update.dart';
import '../../features/alerts/presentation/cubit/alerts_cubit.dart';
import '../../features/alerts/presentation/pages/alerts_screen.dart';
import '../../features/map/presentation/pages/route_map_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/rounds/presentation/cubit/reminders_cubit.dart';
import '../../features/rounds/presentation/cubit/rounds_cubit.dart';
import '../../features/rounds/presentation/pages/rounds_screen.dart';
import '../../features/rounds/presentation/pages/student_home_screen.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import 'adaptive_shell.dart';

/// The five student tabs from the Figma file.
class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

  static const int alertsTabIndex = 3;

  /// True when [current] has an update that [previous] did not have.
  static bool hasNewUpdate(AlertsState previous, AlertsState current) {
    final StatusUpdate? latest = current.latest;
    if (previous.status != AlertsStatus.ready || latest == null) {
      return false;
    }
    return !previous.updates.any((StatusUpdate u) => u.id == latest.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlertsCubit, AlertsState>(
      listenWhen: hasNewUpdate,
      listener: (BuildContext context, AlertsState state) {
        if (!context.read<SettingsCubit>().state.showAlertBanners) {
          return;
        }
        final StatusUpdate update = state.latest!;
        final String? roundLabel = context
            .read<RoundsCubit>()
            .state
            .byId(update.roundId)
            ?.label;
        final bool reminded = context.read<RemindersCubit>().state.has(
          update.roundId,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryDark,
              content: Row(
                children: <Widget>[
                  const AppIcon(AppIcons.bell, size: 18, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${reminded ? 'Reminder: ' : ''}'
                      '${roundLabel ?? 'Bus'}: ${update.type.label}',
                    ),
                  ),
                ],
              ),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () =>
                    context.read<ShellTabCubit>().select(alertsTabIndex),
              ),
            ),
          );
      },
      child: const AdaptiveShell(
        destinations: <ShellDestination>[
          ShellDestination(
            label: 'Home',
            icon: AppIcons.home,
            page: StudentHomeScreen(),
          ),
          ShellDestination(
            label: 'Map',
            icon: AppIcons.map,
            page: RouteMapScreen(),
          ),
          ShellDestination(
            label: 'Rounds',
            icon: AppIcons.clock,
            page: RoundsScreen(),
          ),
          ShellDestination(
            label: 'Alerts',
            icon: AppIcons.bell,
            page: AlertsScreen(),
          ),
          ShellDestination(
            label: 'Profile',
            icon: AppIcons.user,
            page: ProfileScreen(),
          ),
        ],
      ),
    );
  }
}
