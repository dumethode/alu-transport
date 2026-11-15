import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/update_request.dart';
import '../../domain/repositories/request_repository.dart';
import '../models/update_request_model.dart';

/// [RequestRepository] backed by the `update_requests` collection.
/// Both queries use composite indexes listed in firestore.indexes.json.
class FirestoreRequestRepository implements RequestRepository {
  FirestoreRequestRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('update_requests');

  List<UpdateRequest> _toList(QuerySnapshot<Map<String, dynamic>> query) {
    return query.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              UpdateRequestModel.fromMap(doc.id, doc.data()),
        )
        .toList();
  }

  @override
  Stream<List<UpdateRequest>> watchOpen() {
    return _requests
        .where('status', isEqualTo: RequestStatus.open.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(_toList);
  }

  @override
  Stream<List<UpdateRequest>> watchMine(String studentId) {
    return _requests
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map(_toList);
  }

  @override
  Future<void> create({
    required String roundId,
    required String studentId,
    required String pickupPointId,
  }) {
    return _requests.add(
      UpdateRequestModel.newRequest(
        roundId: roundId,
        studentId: studentId,
        pickupPointId: pickupPointId,
      ),
    );
  }

  @override
  Future<void> reply(String requestId, String reply) {
    return _requests.doc(requestId).update(<String, dynamic>{
      'status': RequestStatus.answered.name,
      'reply': reply,
      'answeredAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String requestId) => _requests.doc(requestId).delete();
}
