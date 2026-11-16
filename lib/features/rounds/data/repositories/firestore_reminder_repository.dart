import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/reminder_repository.dart';

/// [ReminderRepository] using a `reminders` sub-collection under each user.
/// The document id is the round id, so a round can only be saved once.
class FirestoreReminderRepository implements ReminderRepository {
  FirestoreReminderRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> _reminders(String uid) =>
      _db.collection('users').doc(uid).collection('reminders');
  @override
  Stream<Set<String>> watchReminders(String uid) {
    return _reminders(uid).snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> query) => query.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
          .toSet(),
    );
  }

  @override
  Future<void> addReminder(String uid, String roundId) {
    return _reminders(uid).doc(roundId).set(<String, dynamic>{
      'roundId': roundId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeReminder(String uid, String roundId) {
    return _reminders(uid).doc(roundId).delete();
  }
}
