import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

/// Converts a [UserProfile] to and from a Firestore `users` document.
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.role,
    required super.avatarSeed,
    super.pickupPointId,
    super.createdAt,
  });

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      uid: profile.uid,
      fullName: profile.fullName,
      email: profile.email,
      role: profile.role,
      avatarSeed: profile.avatarSeed,
      pickupPointId: profile.pickupPointId,
      createdAt: profile.createdAt,
    );
  }

  factory UserProfileModel.fromMap(String id, Map<String, dynamic> map) {
    final Object? created = map['createdAt'];
    return UserProfileModel(
      uid: id,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] == UserRole.driver.name
          ? UserRole.driver
          : UserRole.student,
      avatarSeed: map['avatarSeed'] as String? ?? id,
      pickupPointId: map['pickupPointId'] as String?,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  /// Field names match the ERD exactly. Timestamps are added by the
  /// repository with FieldValue.serverTimestamp().
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role.name,
      'pickupPointId': pickupPointId,
      'avatarSeed': avatarSeed,
    };
  }
}
