import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

import '../device_location_handler.dart';

//TODO handle error (convert all exception message to user friendly)

abstract class RealTimeLocation {
  Future<void> initialize(ReverseGeocoder reverseGeocoder);

  Stream<Coordinates> startLocationTracking(String idOfUserToTrack);

  void startSharingLocation(
      {@required String currentUserId, double distanceFilter = 50});
}

class ReverseGeocoder {
  Future<String> getCityFromCoordinates(Coordinates coordinates) async {
    final placeMarks = await placemarkFromCoordinates(
      coordinates.latitude,
      coordinates.longitude,
    );
    return placeMarks.first.locality;
  }
}
