import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

export 'package:logging/logging.dart';

class Settings {

  static final Settings _instance = new Settings._private();
  static Settings get instance => _instance;

  final Logger logger = new Logger('Daemon');
  final File log = new File('log/details.log');

  final int writesBeforeClosing = 1000;

  Settings._private() {

    int saveCounter = 0;

    IOSink sink;

    log.createSync(recursive: true);

    Logger.root.level = Level.ALL;

    Logger.root.onRecord.listen((LogRecord logRecord) {

      if (saveCounter == 0) sink = log.openWrite(mode: FileMode.APPEND);

      if (logRecord.level > Level.FINE) {

        sink.writeln(formatContent(logRecord));
        print(formatContent(logRecord));

      }

      else {

        if (! (logRecord.message.contains('Mongo') || (logRecord.message.contains('_sendBuffer')))) {

          sink.writeln(formatContent(logRecord));

        }

      }

      if (saveCounter > writesBeforeClosing)  {

        sink.close();
        saveCounter = 0;

      }

      else saveCounter++;

    });

  }

  String formatContent(LogRecord record) =>
      '${record.level.name}: ${record.time}: ${record.message}';

}

class Color {

  static AnsiPen green = new AnsiPen()..green(bold: true);
  static AnsiPen blue = new AnsiPen()..cyan(bold: true);
  static AnsiPen red = new AnsiPen()..red(bold: true);

}