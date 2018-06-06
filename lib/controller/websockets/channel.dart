import 'dart:async';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:logging/logging.dart';

export 'bitfinex/bitfinex.dart';
export 'blockchain.info/blockchain.dart';

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

  static final Duration pingTimeout = new Duration(seconds: 10);
  static final Duration timeout = new Duration(seconds: 20);
  static final Duration ticker = new Duration(seconds: 1);

  void startStallTimer() {

    timeOutToReconnect = timeout.inSeconds;

    // First ping has no delay
    webSocket.add(pingRequest);

    pingTimer = new Timer.periodic(pingTimeout,(Timer timer) {

      webSocket.add(pingRequest);

    });

    timer = new Timer.periodic(ticker,(Timer timer) {

      timeOutToReconnect--;

      if (timeOutToReconnect == 0) {

        onStallController.add('Channel $name is stalled');

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

    onConnectController = new StreamController();
    onDisconnectController = new StreamController();
    onStallController = new StreamController();
    onHeartBeatController = new StreamController();
    onPongController = new StreamController();

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
      Settings.instance.logger.log(Level.FINE, 'Received pong event from $name channel - $events');

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

    timeOutToReconnect = Channel.timeout.inSeconds;

  }

  Stream<List> get onConnect => onConnectController.stream;
  Stream<List> get onDisconnect => onDisconnectController.stream;
  Stream<List> get onStall => onStallController.stream;
  Stream<List> get onHearBeat => onHeartBeatController.stream;
  Stream<List> get onPong => onPongController.stream;

  bool get isAlive => timeOutToReconnect > 0;

}