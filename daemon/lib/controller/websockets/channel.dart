import 'dart:async';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:logging/logging.dart';

abstract class Channel {

  String pingRequest;

  String name;
  String url;

  StreamController onConnectController;
  StreamController onDisconnectController;
  StreamController onStallController;
  StreamController onHeartBeatController;
  StreamController onPongController;

  WebSocket webSocket;

  Timer timer;
  Timer pingTimer;

  int timeOutToReconnect;
  static const int secondsToTimeOut = 10;

  void startStallTimer() {

    timeOutToReconnect = secondsToTimeOut;

    // Ping the server once per minute
    pingTimer = new Timer.periodic(new Duration(seconds: Channel.secondsToTimeOut),(Timer timer) {

      webSocket.add(pingRequest);

    });

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
    pingTimer.cancel();

    resetTimeOutToReconnect();

  }

  Future connect();
  Future disconnect() async {

    await webSocket.close();
    onDisconnectController.add(webSocket.readyState);

  }

  void closeDefaultStreams() {

    onConnectController.close();
    onDisconnectController.close();
    onStallController.close();
    onHeartBeatController.close();
    onPongController.close();

  }

  void openDefaultStreams() {

    onConnectController = new StreamController.broadcast();
    onDisconnectController = new StreamController.broadcast();
    onStallController = new StreamController.broadcast();
    onHeartBeatController = new StreamController.broadcast();
    onPongController = new StreamController.broadcast();

    addListeners();

  }

  void addListeners() {

    onConnect.listen((events) {

      startStallTimer();
      Settings.instance.logger.log(Level.INFO,'Connected to $name channel');

    });

    onHearBeat.listen((events) {

      Settings.instance.logger.log(Level.FINE, 'Received heartbeat event from $name channel.');

    });

    onPong.listen((events) {

      resetTimeOutToReconnect();
      Settings.instance.logger.log(Level.INFO, 'Received pong event from $name channel - $events');

    });

    onDisconnect.listen((events) {

      stopStallTimer();
      Settings.instance.logger.log(Level.INFO, 'Disconnected from $name channel');

    });

  }

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
  Stream<List> get onPong => onPongController.stream;

  bool get isAlive => timeOutToReconnect > 0;

}