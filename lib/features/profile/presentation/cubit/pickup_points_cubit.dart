import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pickup_point.dart';
import '../../domain/repositories/pickup_point_repository.dart';

enum PickupPointsStatus { initial, loading, ready, failure }

class PickupPointsState extends Equatable {
  const PickupPointsState({
    this.status = PickupPointsStatus.initial,
    this.points = const <PickupPoint>[],
  });

  final PickupPointsStatus status;
  final List<PickupPoint> points;

  /// Finds a stop by id, or null if it does not exist.
  PickupPoint? byId(String? id) {
    for (final PickupPoint point in points) {
      if (point.id == id) {
        return point;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[status, points];
}

/// Streams all pickup points, ordered along the route.
class PickupPointsCubit extends Cubit<PickupPointsState> {
  PickupPointsCubit(this._repository) : super(const PickupPointsState());

  final PickupPointRepository _repository;
  StreamSubscription<List<PickupPoint>>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(const PickupPointsState(status: PickupPointsStatus.loading));
    _subscription = _repository.watchAll().listen(
      (List<PickupPoint> points) => emit(
        PickupPointsState(status: PickupPointsStatus.ready, points: points),
      ),
      onError: (Object error) =>
          emit(const PickupPointsState(status: PickupPointsStatus.failure)),
    );
  }

  /// Drivers add the default stops the first time they sign in.
  Future<void> seedIfEmpty() async {
    try {
      await _repository.seedDefaultsIfEmpty();
    } catch (_) {
      // Not a driver or offline; the list simply stays as it is.
    }
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const PickupPointsState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
