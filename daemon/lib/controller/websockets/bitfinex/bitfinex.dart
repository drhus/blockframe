library websockets.bitfinex;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/model/channel.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'requests.dart';

class BitfinexChannel extends Channel {

  StreamController _onCandlesController = new StreamController.broadcast();

  Db database;
  DbCollection candles;

  BitfinexChannel() {

    name = 'Bitfinex';
    url = 'wss://api.bitfinex.com/ws/2';

  }

  Future connect() async {

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        onConnectController.add(webSocket.readyState);

        webSocket.add(Requests.subscribeToCandles);

        webSocket.listen((event) {

          var data = json.decode(event);

          if (data is List) {

              _onCandlesController.add(data);

            }

          },

          onDone: onDone, onError: onError);

    }

  }

  Future disconnect() async {

    await webSocket.close();

  }

  Stream<List> get onCandles => _onCandlesController.stream;

}