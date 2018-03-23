import 'package:logging/logging.dart';

export 'package:logging/logging.dart';

class Settings {

  static final Settings _instance = new Settings._private();
  static Settings get instance => _instance;

  final Logger logger = new Logger('Daemon');

  Settings._private() {


    Logger.root.level = Level.ALL;

    Logger.root.onRecord.listen((LogRecord logRecord) {

        print(contents(logRecord));

    });

  }

  String contents(LogRecord record) =>
      '${record.level.name}: ${record.time}: ${record.message}';

}