library websockets.bitfinex;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/controller/websockets/channel.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'requests.dart';

class BitfinexChannel extends Channel {

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
    _onCandlesController = new StreamController.broadcast();

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        webSocket.add(Requests.subscribeToCandles);

        webSocket.listen((event) {

          var response = json.decode(event);
          Settings.instance.logger.log(Level.FINE,'Raw data received from websocket: $response');

          if (response is Map) {

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

          if (response is List) {

            // First element is the channel ID
            for (var details in response.sublist(1,response.length)) {

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

  Stream<List> get onCandles => _onCandlesController.stream;

}

