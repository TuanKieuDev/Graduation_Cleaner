import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

final appLogger = AppLogger();

class AppLogger {
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  final _logger = Logger(
    printer: PrettyPrinter(),
  );

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
    analytics.logEvent(
      name: 'error_app',
      parameters: {
        'message': message,
      },
    );
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
