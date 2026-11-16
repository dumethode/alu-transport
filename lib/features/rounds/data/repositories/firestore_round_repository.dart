import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/round.dart';
import '../../domain/repositories/round_repository.dart';
import '../models/round_model.dart';

/// [RoundRepository] backed by the Firestore `rounds` collection.
class FirestoreRoundRepository implements RoundRepository {
  FirestoreRoundRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _rounds =>
      _db.collection('rounds');
  @override
  Stream<List<Round>> watchToday() {
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    return _rounds
        .where(
          'departureTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('departureTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('departureTime')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> query) => query.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    RoundModel.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  @override
  Future<String> createRound(Round round) async {
    final DocumentReference<Map<String, dynamic>> doc = _rounds.doc();
    await doc.set(<String, dynamic>{
      ...RoundModel.fromEntity(round).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
  Future<void> updateRound(Round round) {
    return _rounds.doc(round.id).update(<String, dynamic>{
      ...RoundModel.fromEntity(round).toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateLiveStatus(
    String roundId, {
    required RoundStatus status,
    int? currentStopIndex,
    int? seatsLeft,
    String? note,
  }) {
    final Map<String, dynamic> changes = <String, dynamic>{
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (currentStopIndex != null) {
      changes['currentStopIndex'] = currentStopIndex;
    }
    if (seatsLeft != null) {
      changes['seatsLeft'] = seatsLeft;
    }
    if (note != null) {
      changes['note'] = note;
    }
    return _rounds.doc(roundId).update(changes);
  }

  @override
  Future<void> deleteRound(String roundId) => _rounds.doc(roundId).delete();
}
