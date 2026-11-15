import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/status_update.dart';
import '../../domain/repositories/status_update_repository.dart';
import '../models/status_update_model.dart';

/// [StatusUpdateRepository] backed by the `status_updates` collection.
class FirestoreStatusUpdateRepository implements StatusUpdateRepository {
  FirestoreStatusUpdateRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _updates =>
      _db.collection('status_updates');

  @override
  Stream<List<StatusUpdate>> watchRecent({int limit = 30}) {
    return _updates
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> query) => query.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    StatusUpdateModel.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  @override
  Future<void> post({
    required String roundId,
    required String driverId,
    required StatusUpdateType type,
    String? stopId,
    String? note,
  }) {
    return _updates.add(
      StatusUpdateModel.newUpdate(
        roundId: roundId,
        driverId: driverId,
        type: type,
        stopId: stopId,
        note: note,
      ),
    );
  }

  @override
  Future<void> delete(String updateId) => _updates.doc(updateId).delete();
}
