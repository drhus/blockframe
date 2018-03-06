import 'package:blockframe_server/blockframe_server.dart';
import 'package:aqueduct/test.dart';

export 'package:blockframe_server/blockframe_server.dart';
export 'package:aqueduct/test.dart';
export 'package:test/test.dart';
export 'package:aqueduct/aqueduct.dart';

/// A testing harness for blockframe_server.
///
/// Use instances of this class to start/stop the test blockframe_server server. Use [client] to execute
/// requests against the test server.  This instance will use configuration values
/// from config.src.yaml.
class TestApplication {
  Application<BlockframeServerSink> application;
  BlockframeServerSink get sink => application.mainIsolateSink;
  TestClient client;

  /// Starts running this test harness.
  ///
  /// This method will start an [Application] with [BlockframeServerSink]. Invoke this method
  /// in setUpAll (or setUp, depending on your need).
  ///
  /// You must call [stop] on this instance when tearing down your tests.
  Future start() async {
    RequestController.letUncaughtExceptionsEscape = true;
    application = new Application<BlockframeServerSink>();
    application.configuration.port = 0;
    application.configuration.configurationFilePath = "config.src.yaml";

    await application.start(runOnMainIsolate: true);

    client = new TestClient(application);
  }

  /// Stops running this application harness.
  ///
  /// This method must be invoked in tearDownAll or tearDown to free up operating system
  /// resources.
  Future stop() async {
    await application?.stop();
  }
}
