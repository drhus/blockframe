import 'dart:io';

import 'package:logging/logging.dart';
export 'package:logging/logging.dart';

class Settings {

  static final Settings _instance = new Settings._private();
  static Settings get instance => _instance;

  final Logger logger = new Logger('blockframe');
  final File log = new File('log.txt');

  Settings._private() {

    log.openWrite();

    Logger.root.level = Level.INFO;

    Logger.root.onRecord.listen((LogRecord rec) {

      String contents = '${rec.level.name}: ${rec.time}: ${rec.message}';

      print(contents);
      log.writeAsStringSync(contents);

    });

  }

}