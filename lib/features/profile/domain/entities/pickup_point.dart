import 'package:equatable/equatable.dart';

/// A stop where students wait for the bus (`pickup_points` collection).
class PickupPoint extends Equatable {
  const PickupPoint({
    required this.id,
    required this.name,
    required this.order,
    required this.minutesFromCampus,
  });

  final String id;
  final String name;

  /// Position along the route, starting at 1 after campus.
  final int order;

  /// Normal driving time from campus to this stop.
  final int minutesFromCampus;

  @override
  List<Object?> get props => <Object?>[id, name, order, minutesFromCampus];
}
