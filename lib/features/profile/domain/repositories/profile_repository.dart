import '../entities/user_profile.dart';

/// Reads and writes the signed-in user's document in `users`.
abstract class ProfileRepository {
  /// Emits null while the user has not finished first-time setup.
  Stream<UserProfile?> watchProfile(String uid);

  Future<void> createProfile(UserProfile profile);

  Future<void> updateProfile(
    String uid, {
    String? fullName,
    String? pickupPointId,
    String? avatarSeed,
  });

  /// True when the transport office added this email to `driver_whitelist`.
  Future<bool> isApprovedDriver(String email);
}
