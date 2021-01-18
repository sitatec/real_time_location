import 'package:flutter/cupertino.dart';
import 'package:real_time_location/src/exceptions/base_exception.dart';

class LocationRepositoryException
    extends BaseException<LocationRepositoryExceptionType> {
  const LocationRepositoryException(
      {@required String message,
      @required LocationRepositoryExceptionType exceptionType})
      : super(exceptionType: exceptionType, message: message);

  const LocationRepositoryException.dataAccessFailed()
      : super(
            exceptionType: LocationRepositoryExceptionType.dataAccessFailed,
            message: 'Failed to retrieve location data from the database');
}

enum LocationRepositoryExceptionType { dataAccessFailed }
