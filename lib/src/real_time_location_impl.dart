import 'package:flutter/foundation.dart';
import 'package:real_time_location/src/public_api/real_time_location.dart';
import 'package:real_time_location/src/repositories/location_repository.dart';

import 'device_location_handler.dart';

//TODO handle error (convert all exception message to user friendly)

class RealTimeLocationImpl implements RealTimeLocation {
  final LocationRepository _locationRepository;
  final DeviceLocationHandler _deviceLocationHandler;
  bool _realTimeLocationInitialized = false;
  String city;
  RealTimeLocationImpl({
    @required LocationRepository locationRepository,
    @required DeviceLocationHandler deviceLocationHandler,
  })  : _locationRepository = locationRepository,
        _deviceLocationHandler = deviceLocationHandler;

  Future<void> initialize(ReverseGeocoder reverseGeocoder) async {
    final currentCoordinates =
        await _deviceLocationHandler.getCurrentCoordinates();
    city = await reverseGeocoder.getCityFromCoordinates(currentCoordinates);
    _realTimeLocationInitialized = true;
  }

  Stream<Coordinates> startLocationTracking(String idOfUserToTrack) {
    return _locationRepository
        .getLocationStream(city: city, userUid: idOfUserToTrack)
        .map(
          (coordinatesMap) => Coordinates(
            latitude: coordinatesMap['latitude'],
            longitude: coordinatesMap['longitude'],
          ),
        );
  }

  void startSharingLocation(
      {@required String currentUserId, double distanceFilter = 50}) {
    _deviceLocationHandler
        .getCoordinatesStream(distanceFilter: distanceFilter)
        .listen((coordinates) {
      _locationRepository.updateLocation(
        city: city,
        userUid: currentUserId,
        gpsCoordinates: coordinates.toMap(),
      );
    });
  }
}
