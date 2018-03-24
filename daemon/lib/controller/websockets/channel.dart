import 'dart:async';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:logging/logging.dart';

abstract class Channel {

  String name;
  String url;

  StreamController onConnectController = new StreamController.broadcast();
  StreamController onDisconnectController = new StreamController.broadcast();
  StreamController onStallController = new StreamController.broadcast();
  StreamController onHeartBeatController = new StreamController.broadcast();

  WebSocket webSocket;

  Timer timer;

  int timeOutToReconnect;
  int secondsToTimeOut;

  Channel(int secondsToTimeOut) {

    this.secondsToTimeOut = secondsToTimeOut;

    onConnect.listen((events) {

      Settings.instance.logger.log(Level.INFO,'Connected to $name channel');
      startStallTimer();

    });

    onHearBeat.listen((events) {

      Settings.instance.logger.log(Level.FINE, 'Received heartbeat event from $name channel.');

    });

    onDisconnect.listen((events) {

      Settings.instance.logger.log(Level.INFO, 'Disconnected from $name channel');
      stopStallTimer();

    });

    onStall.listen((events) async {

      if (webSocket.readyState == WebSocket.OPEN) {

        await disconnect();
        await new Future.delayed(new Duration(minutes: 1));
        await connect();

      }

    });

  }

  void startStallTimer() {

    timeOutToReconnect = secondsToTimeOut;

    timer = new Timer.periodic(new Duration(seconds: 1),(Timer timer) {

      timeOutToReconnect--;

      if (timeOutToReconnect == 0) {

        onStallController.add('Channel $name is stalled');

        resetTimeOutToReconnect();

      }

    });

  }

  void stopStallTimer() {

    timer.cancel();
    timeOutToReconnect = secondsToTimeOut;

  }

  Future connect();
  Future disconnect();

  onDone() {

    // TODO Add done event
    //onDisconnectController.add('Bitfinex');

  }

  onError(error) {

    onDisconnectController.add(name);

    Settings.instance.logger.log(Level.INFO, '$name websocket is closed due to an error: $error.');

  }

  /// Resets the timer to the initial value
  void resetTimeOutToReconnect() {

    timeOutToReconnect = secondsToTimeOut;

  }

  Stream<List> get onConnect => onConnectController.stream;
  Stream<List> get onDisconnect => onDisconnectController.stream;
  Stream<List> get onStall => onStallController.stream;
  Stream<List> get onHearBeat => onHeartBeatController.stream;

  bool get isAlive => timeOutToReconnect > 0;

}