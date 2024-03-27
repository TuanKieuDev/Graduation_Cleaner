import 'package:logger/logger.dart';

final appLogger = AppLogger();

class AppLogger {

  final _logger = Logger(
    printer: PrettyPrinter(),
  );

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  void debug(String message) {
    _logger.d(message);
  }

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message) {
    _logger.w(message);
  }
}
