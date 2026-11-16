import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../profile/presentation/cubit/pickup_points_cubit.dart';
import '../../../requests/domain/entities/update_request.dart';
import '../../../requests/presentation/cubit/driver_requests_cubit.dart';
import '../../../rounds/domain/entities/round.dart';
import '../../../rounds/presentation/cubit/rounds_cubit.dart';
import '../cubit/driver_round_cubit.dart';
import '../cubit/driver_round_state.dart';
import '../widgets/seats_stepper.dart';

/// Figma screen 8: seats left on the bus and students' update requests.
class DriverRequestsScreen extends StatelessWidget {
  const DriverRequestsScreen({super.key});

  static const List<String> quickReplies = <String>[
    'On my way',
    '5 min away',
    'Delayed, sorry',
  ];

  @override
  Widget build(BuildContext context) {
    final RoundsState rounds = context.watch<RoundsCubit>().state;
    final DriverRoundState driver = context.watch<DriverRoundCubit>().state;
    final DriverRoundCubit cubit = context.read<DriverRoundCubit>();
    final Round? round = cubit.currentRound(rounds.rounds);

    return Scaffold(
      appBar: AppBar(title: const Text('Seats and requests')),
      body: BlocConsumer<DriverRequestsCubit, DriverRequestsState>(
        listenWhen:
            (DriverRequestsState previous, DriverRequestsState current) =>
                current.message != null && current.message != previous.message,
        listener: (BuildContext context, DriverRequestsState state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<DriverRequestsCubit>().clearMessage();
        },
        builder: (BuildContext context, DriverRequestsState requests) {
          return ResponsiveBody(
            children: <Widget>[
              if (round != null)
                AppCard(
                  child: Column(
                    spacing: 10,
                    children: <Widget>[
                      Text(
                        'Seats left on ${round.label}',
                        style: TextStyle(color: context.mutedText),
                      ),
                      SeatsStepper(
                        value: round.seatsLeft,
                        max: round.seatsTotal,
                        onChanged: (int delta) =>
                            cubit.changeSeats(round, delta),
                      ),
                      AppButton(
                        label: round.status == RoundStatus.full
                            ? 'Bus is marked full'
                            : 'Mark bus full',
                        icon: AppIcons.users,
                        variant: AppButtonVariant.danger,
                        isLoading: driver.isBusy,
                        onPressed: round.status == RoundStatus.full
                            ? null
                            : () => cubit.markFull(round),
                      ),
                    ],
                  ),
                ),
              Text(
                'Update requests',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.mutedText,
                ),
              ),
              if (requests.isLoading)
                const SizedBox(height: 120, child: LoadingView())
              else if (requests.requests.isEmpty)
                const AppCard(
                  child: MessageView(
                    icon: AppIcons.messageCircle,
                    title: 'No requests right now',
                    message: 'When students ask for an update, they show here.',
                  ),
                )
              else
                for (final MapEntry<String, List<UpdateRequest>> group
                    in requests.byPickupPoint.entries)
                  _RequestGroupCard(
                    stopName:
                        context
                            .watch<PickupPointsCubit>()
                            .state
                            .byId(group.key)
                            ?.name ??
                        'Unknown stop',
                    requests: group.value,
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestGroupCard extends StatelessWidget {
  const _RequestGroupCard({required this.stopName, required this.requests});

  final String stopName;
  final List<UpdateRequest> requests;

  @override
  Widget build(BuildContext context) {
    final DriverRequestsCubit cubit = context.read<DriverRequestsCubit>();
    final int count = requests.length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  count == 1 ? '1 student asked' : '$count students asked',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              StatusPill(
                label: stopName,
                icon: AppIcons.mapPin,
                foreground: AppColors.primaryDark,
                background: AppColors.primaryLight,
              ),
            ],
          ),
          Text(
            'Last request ${Formatters.timeAgo(requests.first.createdAt)}',
            style: TextStyle(color: context.mutedText, fontSize: 12.5),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String reply in DriverRequestsScreen.quickReplies)
                ActionChip(
                  avatar: AppIcon(
                    AppIcons.send,
                    size: 16,
                    color: context.colors.primary,
                  ),
                  label: Text(reply),
                  onPressed: () => cubit.replyToAll(requests, reply),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
