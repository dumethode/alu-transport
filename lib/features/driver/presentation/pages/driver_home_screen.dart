import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../rounds/domain/entities/round.dart';
import '../../../rounds/presentation/cubit/rounds_cubit.dart';
import '../../../rounds/presentation/widgets/live_status_card.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/driver_round_cubit.dart';
import '../cubit/driver_round_state.dart';
import '../widgets/round_picker.dart';
import '../widgets/status_preset_grid.dart';
import 'round_form_screen.dart';

/// Figma screen 7: the driver picks a preset update and sends it.
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send(Round round) async {
    FocusScope.of(context).unfocus();
    final bool sent = await context.read<DriverRoundCubit>().sendUpdate(
      round,
      note: _note.text,
    );
    if (sent) {
      _note.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = Formatters.firstName(
      context.watch<ProfileCubit>().state.profile?.fullName ?? '',
    );
    final bool use24Hour = context.watch<SettingsCubit>().state.use24HourTime;
    final RoundsState rounds = context.watch<RoundsCubit>().state;
    final DriverRoundState driver = context.watch<DriverRoundCubit>().state;
    final DriverRoundCubit cubit = context.read<DriverRoundCubit>();
    final Round? round = cubit.currentRound(rounds.rounds);

    final List<Widget> children = <Widget>[
      Text(
        'Hi, $name',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
    ];

    if (rounds.status != RoundsStatus.ready) {
      children.add(const SizedBox(height: 160, child: LoadingView()));
    } else if (round == null) {
      children.add(
        AppCard(
          child: MessageView(
            icon: AppIcons.clock,
            title: 'No rounds today',
            message: 'Add today\'s first round to start posting updates.',
            actionLabel: 'Add a round',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const RoundFormScreen(),
              ),
            ),
          ),
        ),
      );
    } else {
      children.addAll(<Widget>[
        if (rounds.rounds.length > 1)
          RoundPicker(
            rounds: rounds.rounds,
            selectedId: round.id,
            use24Hour: use24Hour,
            onSelected: cubit.selectRound,
          ),
        LiveStatusCard(
          round: round,
          position: rounds.rounds.indexOf(round) + 1,
          totalRounds: rounds.rounds.length,
          use24Hour: use24Hour,
        ),
        Text(
          'Tap one update',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: context.mutedText,
          ),
        ),
        StatusPresetGrid(
          selected: driver.selectedType,
          onSelected: cubit.selectType,
        ),
        AppTextField(
          label: 'Note (optional)',
          controller: _note,
          hint: 'For example: traffic at Remera',
          icon: AppIcons.pencil,
          maxLength: 120,
        ),
        AppButton(
          label: 'Send to students',
          icon: AppIcons.send,
          isLoading: driver.isBusy,
          onPressed: () => _send(round),
        ),
        Text(
          'Post updates only while the bus is parked.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.mutedText, fontSize: 12),
        ),
      ]);
    }

    return Scaffold(body: ResponsiveBody(children: children));
  }
}
