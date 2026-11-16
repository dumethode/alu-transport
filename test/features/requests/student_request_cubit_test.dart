import 'dart:async';

import 'package:alu_transport/features/requests/domain/entities/update_request.dart';
import 'package:alu_transport/features/requests/domain/repositories/request_repository.dart';
import 'package:alu_transport/features/requests/presentation/cubit/student_request_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRequestRepository implements RequestRepository {
  final StreamController<List<UpdateRequest>> mine =
      StreamController<List<UpdateRequest>>.broadcast();
  int created = 0;
  String? deleted;

  @override
  Stream<List<UpdateRequest>> watchOpen() =>
      const Stream<List<UpdateRequest>>.empty();

  @override
  Stream<List<UpdateRequest>> watchMine(String studentId) => mine.stream;

  @override
  Future<void> create({
    required String roundId,
    required String studentId,
    required String pickupPointId,
  }) async {
    created++;
  }

  @override
  Future<void> reply(String requestId, String reply) async {}

  @override
  Future<void> delete(String requestId) async {
    deleted = requestId;
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeRequestRepository repository;
  late StudentRequestCubit cubit;

  setUp(() {
    repository = FakeRequestRepository();
    cubit = StudentRequestCubit(repository)..watch('student-1');
  });

  tearDown(() async {
    await cubit.close();
    await repository.mine.close();
  });

  test('sends a request for the student pickup point', () async {
    await cubit.requestUpdate(roundId: 'r2', pickupPointId: 'kimironko');
    expect(repository.created, 1);
    expect(cubit.state.message, 'Request sent. The driver will reply soon.');
  });

  test('asks for a pickup point first when none is chosen', () async {
    await cubit.requestUpdate(roundId: 'r2', pickupPointId: null);
    expect(repository.created, 0);
    expect(cubit.state.message, contains('pickup point'));
  });

  test('does not send twice while a request is open', () async {
    repository.mine.add(<UpdateRequest>[
      UpdateRequest(
        id: 'q1',
        roundId: 'r2',
        studentId: 'student-1',
        pickupPointId: 'kimironko',
        status: RequestStatus.open,
        createdAt: DateTime(2026, 11, 12, 7, 45),
      ),
    ]);
    await _settle();

    await cubit.requestUpdate(roundId: 'r2', pickupPointId: 'kimironko');
    expect(repository.created, 0);

    await cubit.cancel('q1');
    expect(repository.deleted, 'q1');
  });
}
