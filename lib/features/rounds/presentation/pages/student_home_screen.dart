import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/shell_tab_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/domain/entities/pickup_point.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/cubit/pickup_points_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../requests/presentation/widgets/request_reply_banner.dart';
import '../../../requests/presentation/widgets/request_update_button.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/round.dart';
import '../../domain/services/round_eta.dart';
import '../cubit/rounds_cubit.dart';
import '../widgets/arrival_card.dart';
import '../widgets/live_status_card.dart';

/// Figma screen 3: the student home, with the live bus status first.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  /// Index of the Map tab in the student shell.
  static const int mapTabIndex = 1;
  @override
  Widget build(BuildContext context) {
    final UserProfile? profile = context.watch<ProfileCubit>().state.profile;
    final bool use24Hour = context.watch<SettingsCubit>().state.use24HourTime;
    final PickupPointsState pickups = context.watch<PickupPointsCubit>().state;
    final DateTime now = DateTime.now();
    return Scaffold(
      body: BlocBuilder<RoundsCubit, RoundsState>(
        builder: (BuildContext context, RoundsState roundsState) {
          final List<Widget> children = <Widget>[
            Text(
              '${Formatters.greeting(now)},',
              style: TextStyle(color: context.mutedText),
            ),
            Text(
              Formatters.firstName(profile?.fullName ?? ''),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ];
          if (roundsState.status == RoundsStatus.loading ||
              roundsState.status == RoundsStatus.initial) {
            children.add(const SizedBox(height: 160, child: LoadingView()));
          } else if (roundsState.status == RoundsStatus.failure) {
            children.add(
              MessageView(
                icon: AppIcons.alertTriangle,
                title: 'Could not load the bus status',
                message: 'Check your internet connection and try again.',
                actionLabel: 'Try again',
                onAction: context.read<RoundsCubit>().watchToday,
              ),
            );
          } else {
            children.addAll(
              _buildStatus(
                context,
                rounds: roundsState.rounds,
                profile: profile,
                pickups: pickups,
                use24Hour: use24Hour,
                now: now,
              ),
            );
          }
          return ResponsiveBody(children: children);
        },
      ),
    );
  }

  List<Widget> _buildStatus(
    BuildContext context, {
    required List<Round> rounds,
    required UserProfile? profile,
    required PickupPointsState pickups,
    required bool use24Hour,
    required DateTime now,
  }) {
    final Round? focus = RoundEta.focusRound(rounds, now);
    if (focus == null) {
      return <Widget>[
        const AppCard(
          child: MessageView(
            icon: AppIcons.bus,
            title: 'No bus on the road right now',
            message:
                'Today\'s rounds appear here as soon as the driver adds them.',
          ),
        ),
      ];
    }
    final PickupPoint? myStop = pickups.byId(profile?.pickupPointId);
    final DateTime? arrival = myStop == null
        ? null
        : RoundEta.arrivalAt(round: focus, stop: myStop);
    final Round? lastMorning = RoundEta.lastOfPeriod(
      rounds,
      RoundPeriod.morning,
    );
    return <Widget>[
      LiveStatusCard(
        round: focus,
        position: rounds.indexOf(focus) + 1,
        totalRounds: rounds.length,
        use24Hour: use24Hour,
      ),
      if (myStop != null && arrival != null)
        ArrivalCard(
          stopName: myStop.name,
          arrival: arrival,
          minutesAway:
              RoundEta.minutesUntil(round: focus, stop: myStop, now: now) ?? 0,
          hasPassed: RoundEta.hasPassed(focus, myStop.id),
          use24Hour: use24Hour,
        ),
      if (myStop != null && arrival == null)
        _InfoBanner(
          text: '${focus.label} does not stop at ${myStop.name} today.',
        ),
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget mapButton = AppButton(
            label: 'View on map',
            icon: AppIcons.map,
            onPressed: () => context.read<ShellTabCubit>().select(mapTabIndex),
          );
          final Widget requestButton = RequestUpdateButton(
            roundId: focus.id,
            pickupPointId: profile?.pickupPointId,
          );
          // Side by side on wide screens, stacked on narrow ones.
          if (constraints.maxWidth < 340) {
            return Column(
              spacing: 10,
              children: <Widget>[mapButton, requestButton],
            );
          }
          return Row(
            spacing: 10,
            children: <Widget>[
              Expanded(child: mapButton),
              Expanded(child: requestButton),
            ],
          );
        },
      ),
      RequestReplyBanner(roundId: focus.id),
      if (lastMorning != null && !lastMorning.isFinished)
        _InfoBanner(
          text:
              '${lastMorning.label} '
              '(${Formatters.time(lastMorning.departureTime, use24Hour: use24Hour)}) '
              'is the last morning round today.',
        ),
    ];
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppIcon(
            AppIcons.alertTriangle,
            size: 18,
            color: AppColors.warningText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.warningText,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
