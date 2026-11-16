import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../rounds/domain/entities/round.dart';
import '../../../rounds/presentation/cubit/rounds_cubit.dart';
import '../../../rounds/presentation/widgets/round_tile.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/driver_round_cubit.dart';
import 'round_form_screen.dart';

/// Driver tab to create, edit and delete today's rounds.
class ManageRoundsScreen extends StatelessWidget {
  const ManageRoundsScreen({super.key});

  void _openForm(BuildContext context, [Round? round]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RoundFormScreen(existing: round),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Round round) async {
    final DriverRoundCubit cubit = context.read<DriverRoundCubit>();
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Delete ${round.label}?'),
        content: const Text('Students will no longer see this round.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes ?? false) {
      await cubit.deleteRound(round);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool use24Hour = context.watch<SettingsCubit>().state.use24HourTime;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage rounds')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const AppIcon(AppIcons.plus),
        label: const Text('New round'),
      ),
      body: BlocBuilder<RoundsCubit, RoundsState>(
        builder: (BuildContext context, RoundsState state) {
          if (state.status != RoundsStatus.ready) {
            return const LoadingView();
          }
          if (state.rounds.isEmpty) {
            return Center(
              child: MessageView(
                icon: AppIcons.list,
                title: 'No rounds yet today',
                message: 'Tap New round to add the first one.',
                actionLabel: 'New round',
                onAction: () => _openForm(context),
              ),
            );
          }
          return ResponsiveBody(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            children: <Widget>[
              for (final Round round in state.rounds)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    RoundTile(round: round, use24Hour: use24Hour),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: () => _openForm(context, round),
                          icon: const AppIcon(AppIcons.pencil, size: 18),
                          label: const Text('Edit'),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.danger,
                          ),
                          onPressed: () => _confirmDelete(context, round),
                          icon: const AppIcon(
                            AppIcons.trash,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          label: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
