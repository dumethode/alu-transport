import 'package:equatable/equatable.dart';

/// Students follow the bus. Drivers post its status.
enum UserRole { student, driver }

/// A document in the `users` collection.
class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.avatarSeed,
    this.pickupPointId,
    this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final UserRole role;

  /// Foreign key to `pickup_points`. Only students have one.
  final String? pickupPointId;

  /// Seed for the generated DiceBear avatar. Changing it changes the picture.
  final String avatarSeed;
  final DateTime? createdAt;

  bool get isDriver => role == UserRole.driver;

  @override
  List<Object?> get props => <Object?>[
    uid,
    fullName,
    email,
    role,
    pickupPointId,
    avatarSeed,
    createdAt,
  ];
}
