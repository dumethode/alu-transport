import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

/// [ProfileRepository] backed by the Firestore `users` collection.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((
      DocumentSnapshot<Map<String, dynamic>> snapshot,
    ) {
      final Map<String, dynamic>? data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return UserProfileModel.fromMap(snapshot.id, data);
    });
  }

  @override
  Future<void> createProfile(UserProfile profile) {
    return _users.doc(profile.uid).set(<String, dynamic>{
      ...UserProfileModel.fromEntity(profile).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateProfile(
    String uid, {
    String? fullName,
    String? pickupPointId,
    String? avatarSeed,
  }) {
    final Map<String, dynamic> changes = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (fullName != null) {
      changes['fullName'] = fullName.trim();
    }
    if (pickupPointId != null) {
      changes['pickupPointId'] = pickupPointId;
    }
    if (avatarSeed != null) {
      changes['avatarSeed'] = avatarSeed;
    }
    return _users.doc(uid).update(changes);
  }

  @override
  Future<bool> isApprovedDriver(String email) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection('driver_whitelist')
        .doc(email.trim().toLowerCase())
        .get();
    return doc.exists;
  }
}
