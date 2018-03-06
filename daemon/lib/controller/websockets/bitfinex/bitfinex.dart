library websockets.bitfinex;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';

import 'requests.dart';

class Bitfinex {

  static const url  = 'wss://api.bitfinex.com/ws/2';
  WebSocket webSocket;

  StreamController _onCandlesController = new StreamController.broadcast();

  Future connect() async {

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        Settings.instance.logger.log(Level.INFO,'Connected to ${url}');

        webSocket.add(Requests.subscribeToCandles);

        webSocket.listen((event) {

          var data = JSON.decode(event);

          if (data is List) {

              _onCandlesController.add(data);

            }

          },

        onDone: () {

          Settings.instance.logger.log(Level.INFO, 'Bitfinex websocket is closed.');

        },

        onError: (error) {

          Settings.instance.logger.log(Level.INFO, 'Bitfinex websocket is closed due to an error: $error.');

        });

        break;

    }

  }

  Future disconnect() async {

    await webSocket.close();

  }

  Stream<List> get onCandles => _onCandlesController.stream;

}