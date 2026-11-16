import 'package:alu_transport/features/rounds/data/models/round_model.dart';
import 'package:alu_transport/features/rounds/domain/entities/round.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'round_test_data.dart';

void main() {
  test('toMap then fromMap gives back the same round', () {
    final Round round = sampleRound(
      status: RoundStatus.atStop,
      currentStopIndex: 0,
    );
    final Map<String, dynamic> map = RoundModel.fromEntity(round).toMap();
    expect(map['status'], 'at_stop');
    expect(map['departureTime'], isA<Timestamp>());
    final RoundModel back = RoundModel.fromMap(round.id, map);
    expect(back.status, RoundStatus.atStop);
    expect(back.stopIds, round.stopIds);
    expect(back.departureTime, round.departureTime);
    expect(back.seatsLeft, 12);
  });
  test('unknown status text falls back to planned', () {
    final RoundModel model = RoundModel.fromMap('x', <String, dynamic>{
      'status': 'flying',
    });
    expect(model.status, RoundStatus.planned);
    expect(model.currentStopIndex, -1);
  });
}
