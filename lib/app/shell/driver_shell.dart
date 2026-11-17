import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../features/alerts/presentation/pages/alerts_screen.dart';
import '../../features/driver/presentation/cubit/driver_round_cubit.dart';
import '../../features/driver/presentation/cubit/driver_round_state.dart';
import '../../features/driver/presentation/pages/driver_home_screen.dart';
import '../../features/driver/presentation/pages/driver_requests_screen.dart';
import '../../features/driver/presentation/pages/manage_rounds_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import 'adaptive_shell.dart';

/// The driver tabs. Messages from the driver cubit are shown here once,
/// so they do not repeat on every tab.
class DriverShell extends StatelessWidget {
  const DriverShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverRoundCubit, DriverRoundState>(
      listenWhen: (DriverRoundState previous, DriverRoundState current) =>
          current.message != null && current.message != previous.message,
      listener: (BuildContext context, DriverRoundState state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.isError
                  ? AppColors.danger
                  : AppColors.primaryDark,
            ),
          );
        context.read<DriverRoundCubit>().clearMessage();
      },
      child: const AdaptiveShell(
        destinations: <ShellDestination>[
          ShellDestination(
            label: 'Home',
            icon: AppIcons.home,
            page: DriverHomeScreen(),
          ),
          ShellDestination(
            label: 'Rounds',
            icon: AppIcons.list,
            page: ManageRoundsScreen(),
          ),
          ShellDestination(
            label: 'Requests',
            icon: AppIcons.messageCircle,
            page: DriverRequestsScreen(),
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
