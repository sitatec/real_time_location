import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:real_time_location/src/device_location_handler.dart';
import 'package:real_time_location/src/public_api/real_time_location.dart';
import 'package:real_time_location/src/real_time_location_impl.dart';
import 'package:real_time_location/src/repositories/location_repository.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

class MockDeviceLocationHandler extends Mock implements DeviceLocationHandler {}

class MockReverseGeocoder extends Mock implements ReverseGeocoder {}

void main() {
  RealTimeLocation realTimeLocation;
  LocationRepository locationRepository;
  DeviceLocationHandler deviceLocationHandler;
  final reverseGeocoder = MockReverseGeocoder();
  const fakeUserId = 'id';
  const fakeCity = 'ccity';
  final fakeUserLocation =
      Coordinates(latitude: 14.356464, longitude: -12.376404);

  setUp(() async {
    locationRepository = MockLocationRepository();
    deviceLocationHandler = MockDeviceLocationHandler();
    realTimeLocation = RealTimeLocationImpl(
        locationRepository: locationRepository,
        deviceLocationHandler: deviceLocationHandler);
    when(reverseGeocoder.getCityFromCoordinates(fakeUserLocation))
        .thenAnswer((_) => Future.value(fakeCity));
    when(deviceLocationHandler.getCurrentCoordinates())
        .thenAnswer((_) => Future.value(fakeUserLocation));
    await realTimeLocation.initialize(reverseGeocoder);
  });

  test('Should initialize RealTimeLocation', () async {
    await realTimeLocation.initialize(reverseGeocoder);
    verifyInOrder([
      deviceLocationHandler.getCurrentCoordinates(),
      reverseGeocoder.getCityFromCoordinates(fakeUserLocation)
    ]);
  });

  test('Should tack the location of the user which id given as parameter',
      () async {
    when(locationRepository.getLocationStream(
            city: fakeCity, userUid: fakeUserId))
        .thenAnswer((_) => Stream.value(fakeUserLocation.toMap()));
    expect(
      await realTimeLocation.startLocationTracking(fakeUserId).first,
      equals(fakeUserLocation),
    );
  });

  test('Should share current user location', () async {
    when(deviceLocationHandler.getCoordinatesStream(distanceFilter: 100))
        .thenAnswer((_) => Stream.value(fakeUserLocation));
    realTimeLocation.startSharingLocation(
        currentUserId: fakeUserId, distanceFilter: 100);
    await Future.delayed(Duration.zero);
    verifyInOrder([
      deviceLocationHandler.getCoordinatesStream(distanceFilter: 100),
      locationRepository.updateLocation(
        city: fakeCity,
        userUid: fakeUserId,
        gpsCoordinates: fakeUserLocation.toMap(),
      )
    ]);
  });
}
