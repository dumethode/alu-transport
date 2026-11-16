import '../entities/round.dart';

/// Read today's rounds (students and drivers) and change them (drivers).
abstract class RoundRepository {
  Stream<List<Round>> watchToday();

  /// Returns the new round's id.
  Future<String> createRound(Round round);

  /// Saves an edited round (name, time, stops, seats).
  Future<void> updateRound(Round round);

  /// Saves a live change posted by the driver.
  Future<void> updateLiveStatus(
    String roundId, {
    required RoundStatus status,
    int? currentStopIndex,
    int? seatsLeft,
    String? note,
  });
  Future<void> deleteRound(String roundId);
}
