import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/status_update.dart';
import '../../domain/repositories/status_update_repository.dart';

enum AlertsStatus { initial, loading, ready, failure }

class AlertsState extends Equatable {
  const AlertsState({
    this.status = AlertsStatus.initial,
    this.updates = const <StatusUpdate>[],
    this.message,
  });

  final AlertsStatus status;

  /// Newest first.
  final List<StatusUpdate> updates;
  final String? message;

  StatusUpdate? get latest => updates.isEmpty ? null : updates.first;

  AlertsState copyWith({
    AlertsStatus? status,
    List<StatusUpdate>? updates,
    String? message,
    bool clearMessage = false,
  }) {
    return AlertsState(
      status: status ?? this.status,
      updates: updates ?? this.updates,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, updates, message];
}

/// Streams the driver's status updates. Students read them; the driver
/// can also delete his own updates.
class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this._repository) : super(const AlertsState());

  final StatusUpdateRepository _repository;
  StreamSubscription<List<StatusUpdate>>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(const AlertsState(status: AlertsStatus.loading));
    _subscription = _repository.watchRecent().listen(
      (List<StatusUpdate> updates) =>
          emit(state.copyWith(status: AlertsStatus.ready, updates: updates)),
      onError: (Object error) => emit(
        state.copyWith(
          status: AlertsStatus.failure,
          message: 'Could not load alerts.',
        ),
      ),
    );
  }

  Future<void> delete(String updateId) async {
    // Remove it from the list at once, so the swiped card disappears.
    emit(
      state.copyWith(
        updates: state.updates
            .where((StatusUpdate update) => update.id != updateId)
            .toList(),
      ),
    );
    try {
      await _repository.delete(updateId);
      emit(state.copyWith(message: 'Update deleted.'));
    } catch (_) {
      emit(state.copyWith(message: 'Could not delete. Please try again.'));
    }
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const AlertsState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
