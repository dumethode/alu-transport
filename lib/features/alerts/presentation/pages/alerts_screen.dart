import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/cubit/pickup_points_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../rounds/presentation/cubit/rounds_cubit.dart';
import '../../domain/entities/status_update.dart';
import '../cubit/alerts_cubit.dart';
import '../widgets/alert_tile.dart';

/// Figma screen 6: every update from the driver, with the time it was sent.
/// A driver can swipe his own updates away to delete them.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete this update?'),
        content: const Text('Students will no longer see it.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return yes ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile? profile = context.watch<ProfileCubit>().state.profile;
    final RoundsState rounds = context.watch<RoundsCubit>().state;
    final PickupPointsState pickups = context.watch<PickupPointsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: BlocConsumer<AlertsCubit, AlertsState>(
        listenWhen: (AlertsState previous, AlertsState current) =>
            current.message != null && current.message != previous.message,
        listener: (BuildContext context, AlertsState state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<AlertsCubit>().clearMessage();
        },
        builder: (BuildContext context, AlertsState state) {
          if (state.status == AlertsStatus.loading ||
              state.status == AlertsStatus.initial) {
            return const LoadingView();
          }
          if (state.updates.isEmpty) {
            return const Center(
              child: MessageView(
                icon: AppIcons.bell,
                title: 'No alerts yet',
                message: 'Updates from the driver will appear here.',
              ),
            );
          }
          return ResponsiveBody(
            spacing: 8,
            children: <Widget>[
              Text(
                profile?.isDriver ?? false
                    ? 'Swipe one of your updates to delete it.'
                    : "Every alert comes from the driver's app, with the time "
                          'it was sent.',
                style: TextStyle(color: context.mutedText, fontSize: 12.5),
              ),
              for (final StatusUpdate update in state.updates)
                _buildTile(context, update, profile, rounds, pickups),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    StatusUpdate update,
    UserProfile? profile,
    RoundsState rounds,
    PickupPointsState pickups,
  ) {
    final Widget tile = AlertTile(
      update: update,
      roundLabel: rounds.byId(update.roundId)?.label,
      stopName: pickups.byId(update.stopId)?.name,
    );
    final bool canDelete =
        profile != null && profile.isDriver && update.driverId == profile.uid;
    if (!canDelete) {
      return tile;
    }
    return Dismissible(
      key: ValueKey<String>(update.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<AlertsCubit>().delete(update.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: const AppIcon(AppIcons.trash, color: Colors.white),
      ),
      child: tile,
    );
  }
}
