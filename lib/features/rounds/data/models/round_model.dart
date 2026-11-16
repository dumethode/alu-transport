import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/round.dart';

/// Converts a [Round] to and from a Firestore `rounds` document.
class RoundModel extends Round {
  const RoundModel({
    required super.id,
    required super.label,
    required super.period,
    required super.departureTime,
    required super.stopIds,
    required super.status,
    required super.currentStopIndex,
    required super.seatsTotal,
    required super.seatsLeft,
    required super.driverId,
    super.note,
    super.updatedAt,
  });
  factory RoundModel.fromEntity(Round round) {
    return RoundModel(
      id: round.id,
      label: round.label,
      period: round.period,
      departureTime: round.departureTime,
      stopIds: round.stopIds,
      status: round.status,
      currentStopIndex: round.currentStopIndex,
      seatsTotal: round.seatsTotal,
      seatsLeft: round.seatsLeft,
      driverId: round.driverId,
      note: round.note,
      updatedAt: round.updatedAt,
    );
  }
  factory RoundModel.fromMap(String id, Map<String, dynamic> map) {
    final Object? departure = map['departureTime'];
    final Object? updated = map['updatedAt'];
    final List<dynamic> rawStops =
        map['stopIds'] as List<dynamic>? ?? <dynamic>[];
    return RoundModel(
      id: id,
      label: map['label'] as String? ?? 'Round',
      period: map['period'] == RoundPeriod.evening.name
          ? RoundPeriod.evening
          : RoundPeriod.morning,
      departureTime: departure is Timestamp
          ? departure.toDate()
          : DateTime.now(),
      stopIds: rawStops.whereType<String>().toList(),
      status: RoundStatus.fromValue(map['status'] as String?),
      currentStopIndex: (map['currentStopIndex'] as num?)?.toInt() ?? -1,
      seatsTotal: (map['seatsTotal'] as num?)?.toInt() ?? 0,
      seatsLeft: (map['seatsLeft'] as num?)?.toInt() ?? 0,
      driverId: map['driverId'] as String? ?? '',
      note: map['note'] as String?,
      updatedAt: updated is Timestamp ? updated.toDate() : null,
    );
  }

  /// Field names match the ERD. createdAt and updatedAt are added by the
  /// repository with server timestamps.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'period': period.name,
      'departureTime': Timestamp.fromDate(departureTime),
      'stopIds': stopIds,
      'status': status.value,
      'currentStopIndex': currentStopIndex,
      'seatsTotal': seatsTotal,
      'seatsLeft': seatsLeft,
      'driverId': driverId,
      'note': note,
    };
  }
}
