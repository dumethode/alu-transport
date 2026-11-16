import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/domain/entities/pickup_point.dart';
import '../../../profile/presentation/cubit/pickup_points_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/round.dart';
import '../cubit/reminders_cubit.dart';
import '../cubit/rounds_cubit.dart';
import '../widgets/round_tile.dart';

/// Figma screen 5: today's rounds, seats and reminders.
class RoundsScreen extends StatelessWidget {
  const RoundsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bool use24Hour = context.watch<SettingsCubit>().state.use24HourTime;
    final PickupPoint? myStop = context.watch<PickupPointsCubit>().state.byId(
      context.watch<ProfileCubit>().state.profile?.pickupPointId,
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Today's rounds")),
      body: BlocListener<RemindersCubit, RemindersState>(
        listenWhen: (RemindersState previous, RemindersState current) =>
            current.message != null && current.message != previous.message,
        listener: (BuildContext context, RemindersState state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<RemindersCubit>().clearMessage();
        },
        child: BlocBuilder<RoundsCubit, RoundsState>(
          builder: (BuildContext context, RoundsState state) {
            if (state.status != RoundsStatus.ready) {
              return const LoadingView();
            }
            if (state.rounds.isEmpty) {
              return const Center(
                child: MessageView(
                  icon: AppIcons.clock,
                  title: 'No rounds yet today',
                  message: 'The driver has not added today\'s rounds.',
                ),
              );
            }
            final RemindersState reminders = context
                .watch<RemindersCubit>()
                .state;
            return ResponsiveBody(
              children: <Widget>[
                if (myStop != null)
                  Text(
                    '${myStop.name} pickup point',
                    style: TextStyle(color: context.mutedText),
                  ),
                for (final Round round in state.rounds)
                  RoundTile(
                    round: round,
                    use24Hour: use24Hour,
                    hasReminder: reminders.has(round.id),
                    onToggleReminder: () => context
                        .read<RemindersCubit>()
                        .toggle(round.id, roundLabel: round.label),
                  ),
                if (state.rounds.every((Round round) => round.isFinished))
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSurface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.buttonRadius,
                      ),
                    ),
                    child: const Text(
                      'No more rounds today. Plan another way home.',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
