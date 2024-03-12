import 'package:phone_cleaner/src/commons/commons.dart';

class CleanerException implements Exception {
  final ErrorCode errorCode;
  final dynamic message;

  CleanerException({this.errorCode = ErrorCode.internalError, this.message});

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return runtimeType.toString();
    return "${runtimeType.toString()} - ${errorCode.code}: $message";
  }
}

class InvalidStateException extends CleanerException {
  InvalidStateException([dynamic exception]) : super(message: exception);
}
