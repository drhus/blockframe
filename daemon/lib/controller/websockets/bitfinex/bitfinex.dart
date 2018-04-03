library websockets.bitfinex;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/controller/websockets/channel.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'requests.dart';

class BitfinexChannel extends Channel {

  /// Channel ID
  int id;

  StreamController _onCandlesController;

  Db database;
  DbCollection candles;

  BitfinexChannel() {

    name = 'Bitfinex';
    url = 'wss://api.bitfinex.com/ws/2';

  }

  Future connect() async {

    openDefaultStreams();
    _onCandlesController = new StreamController();

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        webSocket.add(Requests.subscribeToCandles);

        webSocket.listen((event) {

          var response = json.decode(event);
          Settings.instance.logger.log(Level.FINE,'Raw data received from websocket: $response');

          _handleResponse(response);

        },

        onDone: onDone, onError: onError);

      break;

    }

  }

  Future disconnect() async {

    await webSocket.close();

    onDisconnectController.add(webSocket.readyState);

    _onCandlesController.close();
    closeDefaultStreams();

  }

  void openStreams() {

    openDefaultStreams();
    _onCandlesController = new StreamController.broadcast();

  }

  void closeStreams() {

    closeDefaultStreams();
    _onCandlesController.close();

  }

  void _handleResponse(response) {

    if (response is Map) {

      _handleEvents(response);

    }

    else if (response is List) {

      if (response.last is String) {

        _handleHeartBeat(response);

      }

      else if (response.last is List){

        _onCandlesController.add(response.last);

      }

    }

  }

  void _handleHeartBeat(List response) {

    if (response.last == 'hb') {

      // Adds channel ID to the stream
      onHeartBeatController.add(response.first);

    }
  }

  void _handleEvents(Map response) {

    if (response.containsKey('event')) {

      switch (response['event']) {

        case 'pong':

          onPongController.add(response);
          break;

        case 'subscribed':

          id = response['chanId'];
          pingRequest = Requests.ping(id);

          onConnectController.add(webSocket.readyState);

          break;

      }

    }

  }

  Stream<List> get onCandles => _onCandlesController.stream;

}

