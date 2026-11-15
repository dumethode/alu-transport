import 'package:equatable/equatable.dart';

enum RequestStatus { open, answered }

/// A student asking the driver "where is the bus?" (`update_requests`).
class UpdateRequest extends Equatable {
  const UpdateRequest({
    required this.id,
    required this.roundId,
    required this.studentId,
    required this.pickupPointId,
    required this.status,
    required this.createdAt,
    this.reply,
    this.answeredAt,
  });

  final String id;

  /// Foreign keys to `rounds`, `users` and `pickup_points`.
  final String roundId;
  final String studentId;
  final String pickupPointId;

  final RequestStatus status;
  final String? reply;
  final DateTime createdAt;
  final DateTime? answeredAt;

  bool get isOpen => status == RequestStatus.open;

  @override
  List<Object?> get props => <Object?>[
    id,
    roundId,
    studentId,
    pickupPointId,
    status,
    reply,
    createdAt,
    answeredAt,
  ];
}
