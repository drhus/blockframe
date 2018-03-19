import 'dart:async';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:logging/logging.dart';

class Channel {

  String name;
  String url;

  StreamController onConnectController = new StreamController.broadcast();
  StreamController onDisconnectController = new StreamController.broadcast();

  WebSocket webSocket;

  Channel() {

    onDisconnect.listen((event) => new Future.delayed(new Duration(minutes: 1)).then((_) => connect()));
    onConnect.listen((event) => Settings.instance.logger.log(Level.INFO,'Connected to $name websocket'));

  }

  Future connect() {}
  Future disconnect() {}

  onDone() {

    onDisconnectController.add('Bitfinex');

  }

  onError(error) {

    onDisconnectController.add(name);

    Settings.instance.logger.log(Level.INFO, '$name websocket is closed due to an error: $error.');

  }

  Stream<List> get onConnect => onConnectController.stream;
  Stream<List> get onDisconnect => onDisconnectController.stream;

}