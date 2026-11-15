import '../entities/update_request.dart';

/// Students create and cancel requests; the driver reads and answers them.
abstract class RequestRepository {
  /// All open requests, newest first (driver).
  Stream<List<UpdateRequest>> watchOpen();

  /// The student's own requests, newest first.
  Stream<List<UpdateRequest>> watchMine(String studentId);

  Future<void> create({
    required String roundId,
    required String studentId,
    required String pickupPointId,
  });

  Future<void> reply(String requestId, String reply);

  Future<void> delete(String requestId);
}
