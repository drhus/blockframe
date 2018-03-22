library websockets.bitfinex;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/websockets/channel.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'requests.dart';

class BitfinexChannel extends Channel {

  StreamController _onCandlesController = new StreamController.broadcast();

  Db database;
  DbCollection candles;

  BitfinexChannel({int secondsToTimeOut = 600}) : super(secondsToTimeOut) {

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

            // First element is the channel ID
            for (var details in data.sublist(1,data.length)) {

              if (details is List) {

                _onCandlesController.add(details);

              }

              else if (details is String) {

                // Heartbeat checking
                if (details == 'hb') {

                  // Adds channel ID to the stream
                  onHeartBeatController.add(details[0]);

                }

              }

            }

          }

        },

        onDone: onDone, onError: onError);

    }

  }

  Future disconnect() async {

    await webSocket.close();
    onDisconnectController.add(webSocket.readyState);

  }

  Stream<List> get onCandles => _onCandlesController.stream;

}