abstract class DeviceInfoException implements Exception {
  final dynamic message;
  DeviceInfoException(this.message);
}

class PermissionException extends DeviceInfoException {
  PermissionException(super.message);
}
