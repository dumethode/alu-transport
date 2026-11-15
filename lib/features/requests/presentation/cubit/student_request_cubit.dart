import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/update_request.dart';
import '../../domain/repositories/request_repository.dart';

class StudentRequestState extends Equatable {
  const StudentRequestState({
    this.studentId,
    this.requests = const <UpdateRequest>[],
    this.isSending = false,
    this.message,
  });

  final String? studentId;
  final List<UpdateRequest> requests;
  final bool isSending;
  final String? message;

  /// The student's open request for a round, if there is one.
  UpdateRequest? openFor(String roundId) {
    for (final UpdateRequest request in requests) {
      if (request.roundId == roundId && request.isOpen) {
        return request;
      }
    }
    return null;
  }

  /// The newest answered request for a round, to show the driver's reply.
  UpdateRequest? latestAnswerFor(String roundId) {
    for (final UpdateRequest request in requests) {
      if (request.roundId == roundId && !request.isOpen) {
        return request;
      }
    }
    return null;
  }

  StudentRequestState copyWith({
    List<UpdateRequest>? requests,
    bool? isSending,
    String? message,
    bool clearMessage = false,
  }) {
    return StudentRequestState(
      studentId: studentId,
      requests: requests ?? this.requests,
      isSending: isSending ?? this.isSending,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => <Object?>[studentId, requests, isSending, message];
}

/// The "Request update" button: create, read and cancel (delete) a request.
class StudentRequestCubit extends Cubit<StudentRequestState> {
  StudentRequestCubit(this._repository) : super(const StudentRequestState());

  final RequestRepository _repository;
  StreamSubscription<List<UpdateRequest>>? _subscription;

  void watch(String studentId) {
    _subscription?.cancel();
    emit(StudentRequestState(studentId: studentId));
    _subscription = _repository
        .watchMine(studentId)
        .listen(
          (List<UpdateRequest> requests) =>
              emit(state.copyWith(requests: requests)),
          onError: (Object error) =>
              emit(state.copyWith(message: 'Could not load your requests.')),
        );
  }

  Future<void> requestUpdate({
    required String roundId,
    required String? pickupPointId,
  }) async {
    final String? studentId = state.studentId;
    if (studentId == null) {
      return;
    }
    if (pickupPointId == null) {
      emit(
        state.copyWith(message: 'Choose your pickup point in Profile first.'),
      );
      return;
    }
    if (state.openFor(roundId) != null) {
      emit(
        state.copyWith(message: 'You already asked. The driver will reply.'),
      );
      return;
    }
    emit(state.copyWith(isSending: true, clearMessage: true));
    try {
      await _repository.create(
        roundId: roundId,
        studentId: studentId,
        pickupPointId: pickupPointId,
      );
      emit(
        state.copyWith(
          isSending: false,
          message: 'Request sent. The driver will reply soon.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSending: false,
          message: 'Could not send your request. Please try again.',
        ),
      );
    }
  }

  Future<void> cancel(String requestId) async {
    try {
      await _repository.delete(requestId);
      emit(state.copyWith(message: 'Request cancelled.'));
    } catch (_) {
      emit(state.copyWith(message: 'Could not cancel. Please try again.'));
    }
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const StudentRequestState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
