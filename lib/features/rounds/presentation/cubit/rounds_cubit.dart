import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/round.dart';
import '../../domain/repositories/round_repository.dart';

enum RoundsStatus { initial, loading, ready, failure }

class RoundsState extends Equatable {
  const RoundsState({
    this.status = RoundsStatus.initial,
    this.rounds = const <Round>[],
  });
  final RoundsStatus status;

  /// Today's rounds, earliest first.
  final List<Round> rounds;
  Round? byId(String? id) {
    for (final Round round in rounds) {
      if (round.id == id) {
        return round;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[status, rounds];
}

/// Streams today's rounds. When the driver changes a round, Firestore
/// pushes the change and every screen that listens rebuilds at once.
class RoundsCubit extends Cubit<RoundsState> {
  RoundsCubit(this._repository) : super(const RoundsState());
  final RoundRepository _repository;
  StreamSubscription<List<Round>>? _subscription;
  void watchToday() {
    _subscription?.cancel();
    emit(const RoundsState(status: RoundsStatus.loading));
    _subscription = _repository.watchToday().listen(
      (List<Round> rounds) =>
          emit(RoundsState(status: RoundsStatus.ready, rounds: rounds)),
      onError: (Object error) =>
          emit(const RoundsState(status: RoundsStatus.failure)),
    );
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const RoundsState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
