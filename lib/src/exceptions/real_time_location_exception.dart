import 'package:flutter/cupertino.dart';
import 'package:real_time_location/src/exceptions/base_exception.dart';

class RealTimeLocationException
    extends BaseException<RealTimeLocationExceptionType> {
  const RealTimeLocationException(
      {@required String message,
      @required RealTimeLocationExceptionType exceptionType})
      : super(exceptionType: exceptionType, message: message);

  const RealTimeLocationException.realTimeLocationUninitialized()
      : super(
            message:
                'Real time location service is not initialized before using it',
            exceptionType:
                RealTimeLocationExceptionType.realTimeLocationUninitialized);

  // @override
  // String toString() => 'RealTimeLocationException :\n' + message;
}

enum RealTimeLocationExceptionType {
  // locationPermissionDenied,
  realTimeLocationUninitialized
}
