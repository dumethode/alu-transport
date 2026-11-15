import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pickup_point.dart';
import '../../domain/repositories/pickup_point_repository.dart';
import '../models/pickup_point_model.dart';

/// [PickupPointRepository] backed by the `pickup_points` collection.
class FirestorePickupPointRepository implements PickupPointRepository {
  FirestorePickupPointRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _points =>
      _db.collection('pickup_points');

  @override
  Stream<List<PickupPoint>> watchAll() {
    return _points
        .orderBy('order')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> query) => query.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    PickupPointModel.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  @override
  Future<void> seedDefaultsIfEmpty() async {
    final QuerySnapshot<Map<String, dynamic>> existing = await _points
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return;
    }
    // One batch, so either all stops are written or none.
    final WriteBatch batch = _db.batch();
    for (final PickupPointModel point in PickupPointModel.defaults) {
      batch.set(_points.doc(point.id), point.toMap());
    }
    await batch.commit();
  }
}
