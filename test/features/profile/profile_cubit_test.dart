import 'dart:async';

import 'package:alu_transport/features/profile/domain/entities/user_profile.dart';
import 'package:alu_transport/features/profile/domain/repositories/profile_repository.dart';
import 'package:alu_transport/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:alu_transport/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfileRepository implements ProfileRepository {
  final StreamController<UserProfile?> profiles =
      StreamController<UserProfile?>.broadcast();
  final Set<String> approvedDrivers = <String>{};
  UserProfile? created;
  String? updatedName;

  @override
  Stream<UserProfile?> watchProfile(String uid) => profiles.stream;

  @override
  Future<void> createProfile(UserProfile profile) async {
    created = profile;
    profiles.add(profile);
  }

  @override
  Future<void> updateProfile(
    String uid, {
    String? fullName,
    String? pickupPointId,
    String? avatarSeed,
  }) async {
    updatedName = fullName;
  }

  @override
  Future<bool> isApprovedDriver(String email) async =>
      approvedDrivers.contains(email);
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = ProfileCubit(repository)..watch('uid-1');
  });

  tearDown(() async {
    await cubit.close();
    await repository.profiles.close();
  });

  test('a user without a document must do first-time setup', () async {
    repository.profiles.add(null);
    await _settle();
    expect(cubit.state.status, ProfileStatus.missing);
  });

  test('a student can create a profile', () async {
    final bool ok = await cubit.createProfile(
      uid: 'uid-1',
      email: 'jean@alustudent.com',
      fullName: ' Jean Muhire ',
      role: UserRole.student,
      pickupPointId: 'kimironko',
    );
    await _settle();
    expect(ok, isTrue);
    expect(repository.created?.fullName, 'Jean Muhire');
    expect(cubit.state.status, ProfileStatus.ready);
  });

  test('a driver email that is not approved is refused', () async {
    final bool ok = await cubit.createProfile(
      uid: 'uid-1',
      email: 'someone@gmail.com',
      fullName: 'Not A Driver',
      role: UserRole.driver,
    );
    expect(ok, isFalse);
    expect(repository.created, isNull);
    expect(cubit.state.errorMessage, contains('driver list'));
  });

  test('an approved driver is saved without a pickup point', () async {
    repository.approvedDrivers.add('eric@alueducation.com');
    await cubit.createProfile(
      uid: 'uid-1',
      email: 'eric@alueducation.com',
      fullName: 'Eric',
      role: UserRole.driver,
      pickupPointId: 'kimironko',
    );
    expect(repository.created?.role, UserRole.driver);
    expect(repository.created?.pickupPointId, isNull);
  });

  test('editing the name shows a success message', () async {
    await cubit.createProfile(
      uid: 'uid-1',
      email: 'jean@alustudent.com',
      fullName: 'Jean',
      role: UserRole.student,
      pickupPointId: 'remera',
    );
    await _settle();
    await cubit.updateName('Jean Muhire');
    expect(repository.updatedName, 'Jean Muhire');
    expect(cubit.state.infoMessage, 'Name updated');
  });
}
