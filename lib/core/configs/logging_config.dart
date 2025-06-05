import 'package:logging/logging.dart';
import '../configs/environment_config.dart';

/// Configure application-wide logging
class LoggingConfig {
  static final Logger _logger = Logger('LifeEase');
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    // Set up logging only in development and staging
    if (Environment.isDev || Environment.isStaging) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        // ignore: avoid_print
        print('${record.level.name}: ${record.time}: ${record.message}');
        if (record.error != null) {
          // ignore: avoid_print
          print('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          // ignore: avoid_print
          print('Stack trace: ${record.stackTrace}');
        }
      });
    } else {
      // In production, only log warnings and errors
      Logger.root.level = Level.WARNING;
      // Here you might want to integrate with a crash reporting service
      // like Firebase Crashlytics or Sentry
    }

    _initialized = true;
  }

  static Logger get logger => _logger;
}
