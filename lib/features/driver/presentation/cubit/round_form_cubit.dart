import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/entities/pickup_point.dart';
import '../../../rounds/domain/entities/round.dart';

class RoundFormState extends Equatable {
  const RoundFormState({
    required this.period,
    required this.time,
    required this.stopIds,
    required this.seatsTotal,
    this.showStopsError = false,
  });

  final RoundPeriod period;
  final TimeOfDay time;

  /// Chosen stops, always kept in route order.
  final List<String> stopIds;
  final int seatsTotal;
  final bool showStopsError;

  static const int minSeats = 1;
  static const int maxSeats = 60;

  RoundFormState copyWith({
    RoundPeriod? period,
    TimeOfDay? time,
    List<String>? stopIds,
    int? seatsTotal,
    bool? showStopsError,
  }) {
    return RoundFormState(
      period: period ?? this.period,
      time: time ?? this.time,
      stopIds: stopIds ?? this.stopIds,
      seatsTotal: seatsTotal ?? this.seatsTotal,
      showStopsError: showStopsError ?? this.showStopsError,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    period,
    time,
    stopIds,
    seatsTotal,
    showStopsError,
  ];
}

/// Holds the choices on the create / edit round form.
class RoundFormCubit extends Cubit<RoundFormState> {
  RoundFormCubit({Round? existing})
    : super(
        RoundFormState(
          period: existing?.period ?? RoundPeriod.morning,
          time: existing == null
              ? const TimeOfDay(hour: 7, minute: 0)
              : TimeOfDay.fromDateTime(existing.departureTime),
          stopIds: existing?.stopIds ?? const <String>[],
          seatsTotal: existing?.seatsTotal ?? 29,
        ),
      );

  void setPeriod(RoundPeriod period) => emit(state.copyWith(period: period));

  void setTime(TimeOfDay time) => emit(state.copyWith(time: time));

  void toggleStop(String stopId, List<PickupPoint> allStops) {
    final Set<String> chosen = state.stopIds.toSet();
    if (!chosen.remove(stopId)) {
      chosen.add(stopId);
    }
    final List<String> ordered = <String>[
      for (final PickupPoint point in allStops)
        if (chosen.contains(point.id)) point.id,
    ];
    emit(state.copyWith(stopIds: ordered, showStopsError: false));
  }

  void changeSeats(int delta) {
    int seats = state.seatsTotal + delta;
    if (seats < RoundFormState.minSeats) {
      seats = RoundFormState.minSeats;
    }
    if (seats > RoundFormState.maxSeats) {
      seats = RoundFormState.maxSeats;
    }
    emit(state.copyWith(seatsTotal: seats));
  }

  /// Returns true when at least one stop is chosen.
  bool validate() {
    if (state.stopIds.isNotEmpty) {
      return true;
    }
    emit(state.copyWith(showStopsError: true));
    return false;
  }

  /// Today's date with the chosen time.
  DateTime departureToday({DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    return DateTime(
      today.year,
      today.month,
      today.day,
      state.time.hour,
      state.time.minute,
    );
  }
}
