import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_location/src/repositories/location_repository.dart';

void main() {
  DatabaseReference databaseReference;
  LocationRepository locationRepository;
  const userUid = 'testUid';
  const otherUserUid = 'testNewUid';

  setUp(() {
    databaseReference = MockFirebaseDatabase.instance.reference();
    locationRepository =
        LocationRepository(databaseReference: databaseReference);
  });

  group('Taxi driver infos :', () {
    // Driver infos such as online, current location...
    const coordinates = {'latitude': 14.463742, 'longitude': 11.631249};
    const otherCoordinates = {'latitude': 16.403942, 'longitude': 10.038241};
    const city = 'city';
    MockFirebaseDatabase.instance
        .reference()
        .child(LocationRepository.onlineNode)
        .child(city)
        .set({
      userUid: '${coordinates['latitude']}-${coordinates['longitude']}',
      otherUserUid:
          '${otherCoordinates['latitude']}-${otherCoordinates['longitude']}'
    });
    test(
        'Should return the coordinates of user which uid is passed in parameter',
        () async {
      final _coordinates =
          await locationRepository.getLocation(userUid: userUid, city: city);
      expect(_coordinates, equals(coordinates));
      final _othercoordinates = await locationRepository.getLocation(
          userUid: otherUserUid, city: city);
      expect(_othercoordinates, equals(otherCoordinates));
    });
    test(
        'Should returns null when nonexistent user uid is passed in parameter.',
        () async {
      final _othercoordinates =
          await locationRepository.getLocation(userUid: 'fakeUid', city: city);
      expect(_othercoordinates, isNull);
    });

    test(
        'Should return a stream of coordinates of user whose uid is passed in parameter',
        () async {
      final _coordinatesStream =
          locationRepository.getLocationStream(userUid: userUid, city: city);
      expect(_coordinatesStream, isA<Stream<Map<String, double>>>());
      expect(await _coordinatesStream.first, equals(coordinates));
    });
    // TODO: test write operations on taxi drivers information
    test('Should update the driver location', () async {
      var _coordinates =
          await locationRepository.getLocation(userUid: userUid, city: city);
      expect(_coordinates, equals(coordinates));
      await locationRepository.updateLocation(
          city: city, gpsCoordinates: otherCoordinates, userUid: userUid);
      _coordinates =
          await locationRepository.getLocation(userUid: userUid, city: city);
      expect(_coordinates, equals(otherCoordinates));
    });
  });
}
