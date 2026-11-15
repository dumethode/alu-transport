import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/update_request.dart';
import '../../domain/repositories/request_repository.dart';

class DriverRequestsState extends Equatable {
  const DriverRequestsState({
    this.isLoading = false,
    this.requests = const <UpdateRequest>[],
    this.message,
  });

  final bool isLoading;
  final List<UpdateRequest> requests;
  final String? message;

  /// Open requests grouped by pickup point, so the driver answers a whole
  /// stop with one tap.
  Map<String, List<UpdateRequest>> get byPickupPoint {
    final Map<String, List<UpdateRequest>> groups =
        <String, List<UpdateRequest>>{};
    for (final UpdateRequest request in requests) {
      groups
          .putIfAbsent(request.pickupPointId, () => <UpdateRequest>[])
          .add(request);
    }
    return groups;
  }

  @override
  List<Object?> get props => <Object?>[isLoading, requests, message];
}

/// Driver side of requests: read open ones and answer (update) them.
class DriverRequestsCubit extends Cubit<DriverRequestsState> {
  DriverRequestsCubit(this._repository) : super(const DriverRequestsState());

  final RequestRepository _repository;
  StreamSubscription<List<UpdateRequest>>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(const DriverRequestsState(isLoading: true));
    _subscription = _repository.watchOpen().listen(
      (List<UpdateRequest> requests) =>
          emit(DriverRequestsState(requests: requests)),
      onError: (Object error) =>
          emit(const DriverRequestsState(message: 'Could not load requests.')),
    );
  }

  /// Sends the same quick reply to every request in [requests].
  Future<void> replyToAll(List<UpdateRequest> requests, String reply) async {
    try {
      for (final UpdateRequest request in requests) {
        await _repository.reply(request.id, reply);
      }
      emit(
        DriverRequestsState(
          requests: state.requests,
          message: 'Reply sent to ${requests.length} student(s).',
        ),
      );
    } catch (_) {
      emit(
        DriverRequestsState(
          requests: state.requests,
          message: 'Could not send the reply. Please try again.',
        ),
      );
    }
  }

  void clearMessage() => emit(DriverRequestsState(requests: state.requests));

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const DriverRequestsState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
