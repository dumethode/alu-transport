import 'package:alu_transport/features/profile/data/models/pickup_point_model.dart';
import 'package:alu_transport/features/profile/data/models/user_profile_model.dart';
import 'package:alu_transport/features/profile/domain/entities/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileModel', () {
    test('reads a Firestore users document', () {
      final DateTime created = DateTime(2026, 11, 12, 8, 30);
      final UserProfileModel model =
          UserProfileModel.fromMap('uid-1', <String, dynamic>{
            'uid': 'uid-1',
            'fullName': 'Jean Muhire',
            'email': 'jean@alustudent.com',
            'role': 'student',
            'pickupPointId': 'kimironko',
            'avatarSeed': 'seed-1',
            'createdAt': Timestamp.fromDate(created),
          });
      expect(model.fullName, 'Jean Muhire');
      expect(model.role, UserRole.student);
      expect(model.pickupPointId, 'kimironko');
      expect(model.createdAt, created);
    });

    test('writes the same field names as the ERD', () {
      const UserProfile profile = UserProfile(
        uid: 'uid-2',
        fullName: 'Eric Driver',
        email: 'eric@alueducation.com',
        role: UserRole.driver,
        avatarSeed: 'uid-2',
      );
      final Map<String, dynamic> map = UserProfileModel.fromEntity(
        profile,
      ).toMap();
      expect(map.keys, <String>[
        'uid',
        'fullName',
        'email',
        'role',
        'pickupPointId',
        'avatarSeed',
      ]);
      expect(map['role'], 'driver');
    });

    test('uses safe defaults when fields are missing', () {
      final UserProfileModel model = UserProfileModel.fromMap(
        'uid-3',
        <String, dynamic>{},
      );
      expect(model.role, UserRole.student);
      expect(model.avatarSeed, 'uid-3');
      expect(model.createdAt, isNull);
    });
  });

  test('default pickup points are in route order', () {
    final List<int> orders = PickupPointModel.defaults
        .map((PickupPointModel point) => point.order)
        .toList();
    expect(orders, <int>[1, 2, 3, 4, 5]);
  });
}
