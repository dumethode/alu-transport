import '../entities/pickup_point.dart';

/// Reads the bus stops and lets a driver add the default stops once.
abstract class PickupPointRepository {
  Stream<List<PickupPoint>> watchAll();

  Future<void> seedDefaultsIfEmpty();
}
