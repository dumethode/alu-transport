import 'dart:async';

import 'package:alu_transport/features/alerts/domain/entities/status_update.dart';
import 'package:alu_transport/features/alerts/domain/repositories/status_update_repository.dart';
import 'package:alu_transport/features/alerts/presentation/cubit/alerts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStatusUpdateRepository implements StatusUpdateRepository {
  final StreamController<List<StatusUpdate>> feed =
      StreamController<List<StatusUpdate>>.broadcast();
  final List<String> deleted = <String>[];

  @override
  Stream<List<StatusUpdate>> watchRecent({int limit = 30}) => feed.stream;

  @override
  Future<void> post({
    required String roundId,
    required String driverId,
    required StatusUpdateType type,
    String? stopId,
    String? note,
  }) async {}

  @override
  Future<void> delete(String updateId) async => deleted.add(updateId);
}

StatusUpdate _update(String id, StatusUpdateType type) => StatusUpdate(
  id: id,
  roundId: 'r2',
  driverId: 'driver-1',
  type: type,
  createdAt: DateTime(2026, 11, 12, 7, 40),
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeStatusUpdateRepository repository;
  late AlertsCubit cubit;

  setUp(() {
    repository = FakeStatusUpdateRepository();
    cubit = AlertsCubit(repository)..watch();
  });

  tearDown(() async {
    await cubit.close();
    await repository.feed.close();
  });

  test('starts loading, then shows the newest update first', () async {
    expect(cubit.state.status, AlertsStatus.loading);
    repository.feed.add(<StatusUpdate>[
      _update('b', StatusUpdateType.atPickup),
      _update('a', StatusUpdateType.leavingCampus),
    ]);
    await _settle();
    expect(cubit.state.status, AlertsStatus.ready);
    expect(cubit.state.latest?.id, 'b');
  });

  test('a stream error shows a polite message', () async {
    repository.feed.addError(Exception('offline'));
    await _settle();
    expect(cubit.state.status, AlertsStatus.failure);
    expect(cubit.state.message, 'Could not load alerts.');
  });

  test('delete removes the update at once and calls Firestore', () async {
    repository.feed.add(<StatusUpdate>[
      _update('b', StatusUpdateType.delayed),
      _update('a', StatusUpdateType.leavingCampus),
    ]);
    await _settle();
    await cubit.delete('b');
    expect(repository.deleted, <String>['b']);
    expect(cubit.state.updates.map((StatusUpdate u) => u.id), <String>['a']);
    expect(cubit.state.message, 'Update deleted.');
  });

  test('type values match the Firestore rules', () {
    expect(
      StatusUpdateType.values.map((StatusUpdateType t) => t.value).toList(),
      <String>[
        'leaving_campus',
        'at_pickup',
        'delayed',
        'bus_full',
        'round_ended',
        'no_more_rounds',
      ],
    );
    expect(StatusUpdateType.fromValue('bus_full'), StatusUpdateType.busFull);
  });
}
