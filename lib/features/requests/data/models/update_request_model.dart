import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/update_request.dart';

/// Converts an [UpdateRequest] to and from an `update_requests` document.
class UpdateRequestModel extends UpdateRequest {
  const UpdateRequestModel({
    required super.id,
    required super.roundId,
    required super.studentId,
    required super.pickupPointId,
    required super.status,
    required super.createdAt,
    super.reply,
    super.answeredAt,
  });

  factory UpdateRequestModel.fromMap(String id, Map<String, dynamic> map) {
    final Object? created = map['createdAt'];
    final Object? answered = map['answeredAt'];
    return UpdateRequestModel(
      id: id,
      roundId: map['roundId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      pickupPointId: map['pickupPointId'] as String? ?? '',
      status: map['status'] == RequestStatus.answered.name
          ? RequestStatus.answered
          : RequestStatus.open,
      reply: map['reply'] as String?,
      // A brand new request has no server time yet, so use "now".
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      answeredAt: answered is Timestamp ? answered.toDate() : null,
    );
  }

  /// Fields written when a student creates a request.
  static Map<String, dynamic> newRequest({
    required String roundId,
    required String studentId,
    required String pickupPointId,
  }) {
    return <String, dynamic>{
      'roundId': roundId,
      'studentId': studentId,
      'pickupPointId': pickupPointId,
      'status': RequestStatus.open.name,
      'reply': null,
      'createdAt': FieldValue.serverTimestamp(),
      'answeredAt': null,
    };
  }
}
