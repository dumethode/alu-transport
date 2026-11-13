import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/status_update.dart';

/// Converts a [StatusUpdate] to and from a `status_updates` document.
class StatusUpdateModel extends StatusUpdate {
  const StatusUpdateModel({
    required super.id,
    required super.roundId,
    required super.driverId,
    required super.type,
    required super.createdAt,
    super.stopId,
    super.note,
  });

  factory StatusUpdateModel.fromMap(String id, Map<String, dynamic> map) {
    final Object? created = map['createdAt'];
    return StatusUpdateModel(
      id: id,
      roundId: map['roundId'] as String? ?? '',
      driverId: map['driverId'] as String? ?? '',
      type: StatusUpdateType.fromValue(map['type'] as String?),
      stopId: map['stopId'] as String?,
      note: map['note'] as String?,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  /// Fields written when the driver posts an update.
  static Map<String, dynamic> newUpdate({
    required String roundId,
    required String driverId,
    required StatusUpdateType type,
    String? stopId,
    String? note,
  }) {
    final String? cleanNote = note?.trim();
    return <String, dynamic>{
      'roundId': roundId,
      'driverId': driverId,
      'type': type.value,
      'stopId': stopId,
      'note': (cleanNote == null || cleanNote.isEmpty) ? null : cleanNote,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
