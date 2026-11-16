import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reminder_repository.dart';

class RemindersState extends Equatable {
  const RemindersState({
    this.uid,
    this.roundIds = const <String>{},
    this.message,
  });
  final String? uid;
  final Set<String> roundIds;
  final String? message;
  bool has(String roundId) => roundIds.contains(roundId);
  @override
  List<Object?> get props => <Object?>[uid, roundIds, message];
}

/// "Remind me" on the rounds screen: creates or deletes a reminder.
class RemindersCubit extends Cubit<RemindersState> {
  RemindersCubit(this._repository) : super(const RemindersState());
  final ReminderRepository _repository;
  StreamSubscription<Set<String>>? _subscription;
  void watch(String uid) {
    _subscription?.cancel();
    emit(RemindersState(uid: uid));
    _subscription = _repository
        .watchReminders(uid)
        .listen(
          (Set<String> ids) => emit(RemindersState(uid: uid, roundIds: ids)),
          onError: (Object error) => emit(
            RemindersState(
              uid: uid,
              roundIds: state.roundIds,
              message: 'Could not load your reminders.',
            ),
          ),
        );
  }

  Future<void> toggle(String roundId, {required String roundLabel}) async {
    final String? uid = state.uid;
    if (uid == null) {
      return;
    }
    final bool had = state.has(roundId);
    try {
      if (had) {
        await _repository.removeReminder(uid, roundId);
      } else {
        await _repository.addReminder(uid, roundId);
      }
      emit(
        RemindersState(
          uid: uid,
          roundIds: state.roundIds,
          message: had
              ? 'Reminder removed for $roundLabel'
              : 'We will remind you about $roundLabel',
        ),
      );
    } catch (_) {
      emit(
        RemindersState(
          uid: uid,
          roundIds: state.roundIds,
          message: 'Could not save the reminder. Please try again.',
        ),
      );
    }
  }

  void clearMessage() =>
      emit(RemindersState(uid: state.uid, roundIds: state.roundIds));
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const RemindersState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
