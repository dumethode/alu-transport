import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/domain/entities/pickup_point.dart';
import '../../../profile/presentation/cubit/pickup_points_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../rounds/domain/entities/round.dart';
import '../../../rounds/domain/services/round_eta.dart';
import '../../../rounds/presentation/cubit/rounds_cubit.dart';
import '../../domain/services/route_geometry.dart';
import '../widgets/route_view.dart';
import '../widgets/stop_eta_panel.dart';

/// Figma screen 4: today's route, where the bus is, and arrival times.
class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final RoundsState rounds = context.watch<RoundsCubit>().state;
    final PickupPointsState pickups = context.watch<PickupPointsCubit>().state;
    final String? myStopId = context
        .watch<ProfileCubit>()
        .state
        .profile
        ?.pickupPointId;
    Widget body;
    if (rounds.status != RoundsStatus.ready) {
      body = const LoadingView();
    } else {
      final Round? focus = RoundEta.focusRound(rounds.rounds, DateTime.now());
      body = focus == null
          ? const Center(
              child: MessageView(
                icon: AppIcons.route,
                title: 'No route to show',
                message: 'The map appears when today\'s next round is added.',
              ),
            )
          : _MapLayout(
              round: focus,
              stops: RoundEta.stopsFor(focus, pickups.points),
              myStopId: myStopId,
            );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Live route')),
      body: SafeArea(child: body),
    );
  }
}

class _MapLayout extends StatelessWidget {
  const _MapLayout({
    required this.round,
    required this.stops,
    required this.myStopId,
  });
  final Round round;
  final List<PickupPoint> stops;
  final String? myStopId;
  List<StopEta> _rows(DateTime now) {
    final List<StopEta> rows = <StopEta>[];
    final int next = RoundEta.nextStopIndex(round);
    if (next >= 0 && next < stops.length) {
      final int? minutes = RoundEta.minutesUntil(
        round: round,
        stop: stops[next],
        now: now,
      );
      rows.add(
        StopEta(
          caption: 'Next stop',
          name: stops[next].name,
          eta: Formatters.minutesFromNow(minutes ?? 0),
        ),
      );
    }
    for (final PickupPoint stop in stops) {
      if (stop.id == myStopId) {
        final bool passed = RoundEta.hasPassed(round, stop.id);
        final int? minutes = RoundEta.minutesUntil(
          round: round,
          stop: stop,
          now: now,
        );
        rows.add(
          StopEta(
            caption: 'Your stop',
            name: stop.name,
            eta: passed ? 'passed' : Formatters.minutesFromNow(minutes ?? 0),
          ),
        );
      }
    }
    if (rows.isEmpty) {
      rows.add(
        StopEta(caption: round.label, name: round.status.label, eta: 'today'),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> names = <String>[
      'ALU campus',
      for (final PickupPoint stop in stops) stop.name,
    ];
    int? mine;
    for (int i = 0; i < stops.length; i++) {
      if (stops[i].id == myStopId) {
        mine = i + 1;
      }
    }
    final Widget map = RouteView(
      stopNames: names,
      progress: RouteGeometry.progressFor(round),
      highlightedStop: mine,
    );
    final Widget banner = AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        "Today's route: ${names.join(' → ')}",
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
      ),
    );
    final Widget panel = StopEtaPanel(rows: _rows(DateTime.now()));
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool landscape =
            constraints.maxWidth > constraints.maxHeight &&
            constraints.maxWidth > 560;
        if (landscape) {
          return Row(
            children: <Widget>[
              Expanded(
                child: ColoredBox(color: _mapColor(context), child: map),
              ),
              SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(spacing: 12, children: <Widget>[banner, panel]),
                ),
              ),
            ],
          );
        }
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: banner,
            ),
            Expanded(
              child: ColoredBox(color: _mapColor(context), child: map),
            ),
            Padding(padding: const EdgeInsets.all(16), child: panel),
          ],
        );
      },
    );
  }

  Color _mapColor(BuildContext context) =>
      context.isDarkMode ? const Color(0xFF141C19) : const Color(0xFFEEF1EC);
}
