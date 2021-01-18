import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:real_time_location/src/exceptions/location_repository_exception.dart';

class LocationRepository {
  @visibleForTesting
  static const onlineNode = 'online';
  final DatabaseReference _realTimeDatabase;

  LocationRepository({DatabaseReference databaseReference})
      : _realTimeDatabase =
            databaseReference ?? FirebaseDatabase.instance.reference();

  @override
  Future<Map<String, double>> getLocation(
      {@required String city, @required String userUid}) async {
    try {
      final coordinates =
          await _realTimeDatabase.child('$onlineNode/$city/$userUid').once();
      if (coordinates.value == null) return null;
      return _coordinatesStringToMap(coordinates.value);
    } on DatabaseError {
      throw LocationRepositoryException.dataAccessFailed();
    }
  }

  Map<String, double> _coordinatesStringToMap(String coordinates) {
    final coordinatesList = coordinates.split('-');
    return {
      'latitude': double.tryParse(coordinatesList.first),
      'longitude': double.tryParse(coordinatesList.last)
    };
  }

  @override
  Stream<Map<String, double>> getLocationStream(
      {@required String city, @required String userUid}) async* {
    try {
      final locationStream =
          _realTimeDatabase.child('$onlineNode/$city/$userUid').onValue;
      await for (var event in locationStream) {
        yield _coordinatesStringToMap(event.snapshot.value);
      }
    } on DatabaseError {
      throw LocationRepositoryException.dataAccessFailed();
    }
  }

  @override
  Future<void> deleteLocation(String userUid) {
    // TODO: implement deleteLocation
    throw UnimplementedError();
  }

  @override
  Future<void> updateLocation(
      {String city, String userUid, Map<String, double> gpsCoordinates}) async {
    try {
      await _realTimeDatabase
          .child('$onlineNode/$city/$userUid')
          .set(_coordinatesMapToString(gpsCoordinates));
    } on DatabaseError {
      throw LocationRepositoryException.dataAccessFailed();
    }
  }

  String _coordinatesMapToString(Map<String, double> coordinates) {
    return '${coordinates["latitude"]}-${coordinates["longitude"]}';
  }
}
