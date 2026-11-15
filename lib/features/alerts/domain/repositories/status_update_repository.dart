import '../entities/status_update.dart';

/// Driver posts updates; everyone signed in reads them as alerts.
abstract class StatusUpdateRepository {
  /// Newest first.
  Stream<List<StatusUpdate>> watchRecent({int limit = 30});

  Future<void> post({
    required String roundId,
    required String driverId,
    required StatusUpdateType type,
    String? stopId,
    String? note,
  });

  Future<void> delete(String updateId);
}
