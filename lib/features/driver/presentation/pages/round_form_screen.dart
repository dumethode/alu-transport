import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../profile/domain/entities/pickup_point.dart';
import '../../../profile/presentation/cubit/pickup_points_cubit.dart';
import '../../../rounds/domain/entities/round.dart';
import '../../../rounds/presentation/cubit/rounds_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/driver_round_cubit.dart';
import '../cubit/driver_round_state.dart';
import '../cubit/round_form_cubit.dart';
import '../widgets/seats_stepper.dart';

/// Create a new round, or edit one when [existing] is given.
class RoundFormScreen extends StatelessWidget {
  const RoundFormScreen({super.key, this.existing});

  final Round? existing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoundFormCubit>(
      create: (BuildContext context) => RoundFormCubit(existing: existing),
      child: _RoundFormView(existing: existing),
    );
  }
}

class _RoundFormView extends StatefulWidget {
  const _RoundFormView({required this.existing});

  final Round? existing;

  @override
  State<_RoundFormView> createState() => _RoundFormViewState();
}

class _RoundFormViewState extends State<_RoundFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _label;

  @override
  void initState() {
    super.initState();
    final int count = context.read<RoundsCubit>().state.rounds.length;
    _label = TextEditingController(
      text: widget.existing?.label ?? 'Round ${count + 1}',
    );
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final RoundFormCubit form = context.read<RoundFormCubit>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: form.state.time,
    );
    if (picked != null) {
      form.setTime(picked);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final RoundFormCubit form = context.read<RoundFormCubit>();
    final bool nameOk = _formKey.currentState?.validate() ?? false;
    final bool stopsOk = form.validate();
    if (!nameOk || !stopsOk) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final bool saved = await context.read<DriverRoundCubit>().saveRound(
      existing: widget.existing,
      label: _label.text,
      period: form.state.period,
      departureTime: form.departureToday(),
      stopIds: form.state.stopIds,
      seatsTotal: form.state.seatsTotal,
    );
    if (saved) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool use24Hour = context.watch<SettingsCubit>().state.use24HourTime;
    final List<PickupPoint> points = context
        .watch<PickupPointsCubit>()
        .state
        .points;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New round' : 'Edit round'),
      ),
      body: Form(
        key: _formKey,
        child: BlocBuilder<RoundFormCubit, RoundFormState>(
          builder: (BuildContext context, RoundFormState form) {
            final RoundFormCubit cubit = context.read<RoundFormCubit>();
            final DateTime departure = cubit.departureToday();
            return ResponsiveBody(
              spacing: 14,
              children: <Widget>[
                AppTextField(
                  label: 'Round name',
                  controller: _label,
                  icon: AppIcons.bus,
                  validator: Validators.roundLabel,
                ),
                const _Label('Period'),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<RoundPeriod>(
                    showSelectedIcon: false,
                    segments: <ButtonSegment<RoundPeriod>>[
                      for (final RoundPeriod period in RoundPeriod.values)
                        ButtonSegment<RoundPeriod>(
                          value: period,
                          label: Text(period.label),
                        ),
                    ],
                    selected: <RoundPeriod>{form.period},
                    onSelectionChanged: (Set<RoundPeriod> choice) =>
                        cubit.setPeriod(choice.first),
                  ),
                ),
                const _Label('Leaves campus at'),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const AppIcon(AppIcons.clock, size: 18),
                  label: Text(Formatters.time(departure, use24Hour: use24Hour)),
                ),
                const _Label('Stops (in route order)'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final PickupPoint point in points)
                      FilterChip(
                        label: Text(point.name),
                        selected: form.stopIds.contains(point.id),
                        onSelected: (_) => cubit.toggleStop(point.id, points),
                      ),
                  ],
                ),
                if (form.showStopsError)
                  const Text(
                    'Choose at least one stop',
                    style: TextStyle(color: AppColors.danger, fontSize: 12.5),
                  ),
                const _Label('Seats on the bus'),
                Center(
                  child: SeatsStepper(
                    value: form.seatsTotal,
                    min: RoundFormState.minSeats,
                    max: RoundFormState.maxSeats,
                    onChanged: cubit.changeSeats,
                  ),
                ),
                const SizedBox(height: 4),
                BlocSelector<DriverRoundCubit, DriverRoundState, bool>(
                  selector: (DriverRoundState state) => state.isBusy,
                  builder: (BuildContext context, bool busy) => AppButton(
                    label: widget.existing == null
                        ? 'Add round'
                        : 'Save changes',
                    icon: AppIcons.checkCircle,
                    isLoading: busy,
                    onPressed: _save,
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: context.mutedText,
      ),
    );
  }
}
