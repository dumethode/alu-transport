import '../../domain/entities/pickup_point.dart';

/// Converts a [PickupPoint] to and from a `pickup_points` document.
class PickupPointModel extends PickupPoint {
  const PickupPointModel({
    required super.id,
    required super.name,
    required super.order,
    required super.minutesFromCampus,
  });

  factory PickupPointModel.fromMap(String id, Map<String, dynamic> map) {
    return PickupPointModel(
      id: id,
      name: map['name'] as String? ?? 'Unnamed stop',
      order: (map['order'] as num?)?.toInt() ?? 0,
      minutesFromCampus: (map['minutesFromCampus'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'order': order,
      'minutesFromCampus': minutesFromCampus,
    };
  }

  /// Stops added the first time a driver signs in, so the app is never empty.
  static const List<PickupPointModel> defaults = <PickupPointModel>[
    PickupPointModel(
      id: 'remera',
      name: 'Remera',
      order: 1,
      minutesFromCampus: 10,
    ),
    PickupPointModel(
      id: 'kimironko',
      name: 'Kimironko',
      order: 2,
      minutesFromCampus: 22,
    ),
    PickupPointModel(
      id: 'kacyiru',
      name: 'Kacyiru',
      order: 3,
      minutesFromCampus: 30,
    ),
    PickupPointModel(
      id: 'kicukiro-centre',
      name: 'Kicukiro Centre',
      order: 4,
      minutesFromCampus: 42,
    ),
    PickupPointModel(
      id: 'gisozi',
      name: 'Gisozi',
      order: 5,
      minutesFromCampus: 50,
    ),
  ];
}
