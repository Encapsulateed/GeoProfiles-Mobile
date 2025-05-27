import 'package:flutter/foundation.dart';    // для kReleaseMode
import 'package:logger/logger.dart';
import 'package:logging/logging.dart' as dart_logging show Level, Logger;

final logger = Logger(
  printer: PrettyPrinter(),
  level: kReleaseMode ? Level.warning : Level.debug,
);




void setupDartLogging() {
  dart_logging.Logger.root.level = dart_logging.Level.ALL;
  dart_logging.Logger.root.onRecord.listen((rec) {
    logger.i('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}
