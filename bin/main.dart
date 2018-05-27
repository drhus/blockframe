import 'dart:core';

import 'package:aqueduct/aqueduct.dart';
import 'package:blockframe_daemon/controller/loader.dart';
import 'package:blockframe_daemon/controller/server/blockframe_server_sink.dart';
import 'package:blockframe_daemon/controller/settings.dart';

main(List<String> arguments) async {

  Loader loader = new Loader();

  // Start daemon
  await loader.start();

  // Start server
  var app = new Application<BlockframeServerSink>()

    ..configuration.configurationFilePath = "config.yaml"
    ..configuration.port = 8000;

  await app.start(numberOfInstances: 2);

  Settings.instance.logger.log(Level.INFO,'Application started on port: ${app.configuration.port}.');

}
