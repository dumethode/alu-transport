import 'package:alu_transport/features/alerts/domain/entities/status_update.dart';
import 'package:alu_transport/features/alerts/domain/repositories/status_update_repository.dart';
import 'package:alu_transport/features/driver/presentation/cubit/driver_round_cubit.dart';
import 'package:alu_transport/features/rounds/domain/entities/round.dart';
import 'package:alu_transport/features/rounds/domain/repositories/round_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRoundRepository implements RoundRepository {
  Round? created;
  String? deletedId;
  RoundStatus? lastStatus;
  int? lastSeats;
  bool failWrites = false;

  @override
  Stream<List<Round>> watchToday() => const Stream<List<Round>>.empty();

  @override
  Future<String> createRound(Round round) async {
    created = round;
    return 'new-round';
  }

  @override
  Future<void> updateRound(Round round) async {}

  @override
  Future<void> updateLiveStatus(
    String roundId, {
    required RoundStatus status,
    int? currentStopIndex,
    int? seatsLeft,
    String? note,
  }) async {
    if (failWrites) {
      throw Exception('permission-denied');
    }
    lastStatus = status;
    lastSeats = seatsLeft;
  }

  @override
  Future<void> deleteRound(String roundId) async {
    deletedId = roundId;
  }
}

class FakeStatusUpdateRepository implements StatusUpdateRepository {
  StatusUpdateType? postedType;
  String? postedStopId;

  @override
  Stream<List<StatusUpdate>> watchRecent({int limit = 30}) =>
      const Stream<List<StatusUpdate>>.empty();

  @override
  Future<void> post({
    required String roundId,
    required String driverId,
    required StatusUpdateType type,
    String? stopId,
    String? note,
  }) async {
    postedType = type;
    postedStopId = stopId;
  }

  @override
  Future<void> delete(String updateId) async {}
}

Round _round({String id = 'r1', RoundStatus status = RoundStatus.planned}) =>
    Round(
      id: id,
      label: 'Round 1',
      period: RoundPeriod.morning,
      departureTime: DateTime(2026, 11, 12, 7),
      stopIds: const <String>['remera', 'kimironko'],
      status: status,
      currentStopIndex: -1,
      seatsTotal: 29,
      seatsLeft: 29,
      driverId: 'driver-1',
    );

void main() {
  late FakeRoundRepository rounds;
  late FakeStatusUpdateRepository updates;
  late DriverRoundCubit cubit;

  setUp(() {
    rounds = FakeRoundRepository();
    updates = FakeStatusUpdateRepository();
    cubit = DriverRoundCubit(rounds: rounds, updates: updates)
      ..start('driver-1');
  });

  tearDown(() => cubit.close());

  test('currentRound picks the first round that has not ended', () {
    final List<Round> today = <Round>[
      _round(id: 'r1', status: RoundStatus.ended),
      _round(id: 'r2'),
    ];
    expect(cubit.currentRound(today)?.id, 'r2');
    cubit.selectRound('r1');
    expect(cubit.currentRound(today)?.id, 'r1');
  });

  test(
    'sending "At pickup point" updates the round and posts an alert',
    () async {
      cubit.selectType(StatusUpdateType.atPickup);
      final bool sent = await cubit.sendUpdate(
        _round(status: RoundStatus.onTheWay),
      );

      expect(sent, isTrue);
      expect(rounds.lastStatus, RoundStatus.atStop);
      expect(updates.postedType, StatusUpdateType.atPickup);
      expect(updates.postedStopId, 'remera');
      expect(cubit.state.message, 'Sent "At pickup point" to students');
    },
  );

  test('a failed write shows an error and posts nothing', () async {
    rounds.failWrites = true;
    final bool sent = await cubit.sendUpdate(_round());

    expect(sent, isFalse);
    expect(updates.postedType, isNull);
    expect(cubit.state.isError, isTrue);
  });

  test('saveRound creates a planned round with every seat free', () async {
    final bool ok = await cubit.saveRound(
      label: ' Round 3 ',
      period: RoundPeriod.evening,
      departureTime: DateTime(2026, 11, 12, 17),
      stopIds: const <String>['remera'],
      seatsTotal: 20,
    );

    expect(ok, isTrue);
    expect(rounds.created?.label, 'Round 3');
    expect(rounds.created?.status, RoundStatus.planned);
    expect(rounds.created?.seatsLeft, 20);
    expect(cubit.state.selectedRoundId, 'new-round');
  });

  test('deleteRound removes the round', () async {
    await cubit.deleteRound(_round(id: 'r9'));
    expect(rounds.deletedId, 'r9');
  });
}
