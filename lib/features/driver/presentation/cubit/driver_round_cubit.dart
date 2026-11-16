import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../alerts/domain/entities/status_update.dart';
import '../../../alerts/domain/repositories/status_update_repository.dart';
import '../../../rounds/domain/entities/round.dart';
import '../../../rounds/domain/repositories/round_repository.dart';
import '../../domain/services/live_change.dart';
import 'driver_round_state.dart';

/// Everything the driver does: post updates, change seats and manage
/// rounds (create, update, delete).
class DriverRoundCubit extends Cubit<DriverRoundState> {
  DriverRoundCubit({
    required RoundRepository rounds,
    required StatusUpdateRepository updates,
  }) : _rounds = rounds,
       _updates = updates,
       super(const DriverRoundState());

  final RoundRepository _rounds;
  final StatusUpdateRepository _updates;

  void start(String driverId) => emit(DriverRoundState(driverId: driverId));

  void selectRound(String roundId) =>
      emit(state.copyWith(selectedRoundId: roundId));

  void selectType(StatusUpdateType type) =>
      emit(state.copyWith(selectedType: type));

  /// The round to show: the one the driver picked, otherwise the first
  /// round that has not ended, otherwise the last one.
  Round? currentRound(List<Round> rounds) {
    if (rounds.isEmpty) {
      return null;
    }
    for (final Round round in rounds) {
      if (round.id == state.selectedRoundId) {
        return round;
      }
    }
    for (final Round round in rounds) {
      if (!round.isFinished) {
        return round;
      }
    }
    return rounds.last;
  }

  /// Posts the selected preset: updates the round, then adds an alert.
  Future<bool> sendUpdate(Round round, {String? note}) {
    return _post(round, state.selectedType, note: note);
  }

  Future<bool> markFull(Round round) => _post(round, StatusUpdateType.busFull);

  Future<void> changeSeats(Round round, int delta) async {
    final LiveChange change = LiveChange.forSeats(round, delta);
    if (change.seatsLeft == round.seatsLeft) {
      return;
    }
    try {
      await _rounds.updateLiveStatus(
        round.id,
        status: change.status,
        seatsLeft: change.seatsLeft,
      );
    } catch (_) {
      _fail('Could not update seats. Please try again.');
    }
  }

  Future<bool> saveRound({
    Round? existing,
    required String label,
    required RoundPeriod period,
    required DateTime departureTime,
    required List<String> stopIds,
    required int seatsTotal,
  }) async {
    final String? driverId = state.driverId;
    if (driverId == null) {
      return false;
    }
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      if (existing == null) {
        final String id = await _rounds.createRound(
          Round(
            id: '',
            label: label.trim(),
            period: period,
            departureTime: departureTime,
            stopIds: stopIds,
            status: RoundStatus.planned,
            currentStopIndex: -1,
            seatsTotal: seatsTotal,
            seatsLeft: seatsTotal,
            driverId: driverId,
          ),
        );
        emit(
          state.copyWith(
            isBusy: false,
            selectedRoundId: id,
            message: '${label.trim()} added',
          ),
        );
      } else {
        final int seatsLeft = existing.seatsLeft > seatsTotal
            ? seatsTotal
            : existing.seatsLeft;
        await _rounds.updateRound(
          existing.copyWith(
            label: label.trim(),
            period: period,
            departureTime: departureTime,
            stopIds: stopIds,
            seatsTotal: seatsTotal,
            seatsLeft: seatsLeft,
          ),
        );
        emit(state.copyWith(isBusy: false, message: '${label.trim()} saved'));
      }
      return true;
    } catch (_) {
      _fail('Could not save the round. Please try again.');
      return false;
    }
  }

  Future<void> deleteRound(Round round) async {
    try {
      await _rounds.deleteRound(round.id);
      emit(state.copyWith(message: '${round.label} deleted'));
    } catch (_) {
      _fail('Could not delete the round. Please try again.');
    }
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  void reset() => emit(const DriverRoundState());

  Future<bool> _post(Round round, StatusUpdateType type, {String? note}) async {
    final String? driverId = state.driverId;
    if (driverId == null) {
      return false;
    }
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final LiveChange change = LiveChange.forUpdate(round, type);
    final String? stopId =
        type == StatusUpdateType.atPickup &&
            change.currentStopIndex >= 0 &&
            change.currentStopIndex < round.stopIds.length
        ? round.stopIds[change.currentStopIndex]
        : null;
    try {
      await _rounds.updateLiveStatus(
        round.id,
        status: change.status,
        currentStopIndex: change.currentStopIndex,
        seatsLeft: change.seatsLeft,
        note: note?.trim() ?? '',
      );
      await _updates.post(
        roundId: round.id,
        driverId: driverId,
        type: type,
        stopId: stopId,
        note: note,
      );
      emit(
        state.copyWith(
          isBusy: false,
          message: 'Sent "${type.label}" to students',
        ),
      );
      return true;
    } catch (_) {
      _fail('Could not send the update. Check your connection.');
      return false;
    }
  }

  void _fail(String message) =>
      emit(state.copyWith(isBusy: false, message: message, isError: true));
}
