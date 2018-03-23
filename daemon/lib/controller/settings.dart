import 'dart:io';

import 'package:logging/logging.dart';
export 'package:logging/logging.dart';

class Settings {

  static final Settings _instance = new Settings._private();
  static Settings get instance => _instance;

  final Logger logger = new Logger('blockframe');

  Settings._private() {

    Logger.root.level = Level.INFO;

    Logger.root.onRecord.listen((LogRecord rec) async {

      String contents = '${rec.level.name}: ${rec.time}: ${rec.message}';

      print(contents);

    });

  }

}