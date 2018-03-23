import 'dart:io';

import 'package:logging/logging.dart';
export 'package:logging/logging.dart';

class Settings {

  static final Settings _instance = new Settings._private();
  static Settings get instance => _instance;

  final Logger logger = new Logger('blockframe');
  final File log = new File('log/log.txt');

  Settings._private() {

    if (! log.existsSync()) {

      log.createSync(recursive: true);

    }

    IOSink sink = log.openWrite(mode: FileMode.APPEND);

    Logger.root.level = Level.INFO;

    Logger.root.onRecord.listen((LogRecord rec) async {

      String contents = '${rec.level.name}: ${rec.time}: ${rec.message}';

      print(contents);
      sink.writeln(contents);

      await sink.flush();

    });

  }

}