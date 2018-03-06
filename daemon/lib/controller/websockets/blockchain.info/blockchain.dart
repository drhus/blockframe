library websockets.blockchain.info;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';

import 'requests.dart';

class BlockChain {

  static const url  = 'wss://ws.blockchain.info/inv';

  StreamController _onBlockFramesController = new StreamController.broadcast();

  WebSocket webSocket;

  Future connect() async {

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        Settings.instance.logger.log(Level.INFO,'Connected to ${url}');

        webSocket.add(Requests.ping);
        webSocket.add(Requests.subscribeToBlocks);

        // Ping the server once per minute
        // new Future.delayed(new Duration(minutes: 1)).then((event) => webSocket.add(Requests.ping));

        webSocket.listen((event) {

          var data = JSON.decode(event);

          switch(data['op']) {

            case 'pong':

              Settings.instance.logger.log(Level.INFO, 'Received pong from $url');
              break;

            case 'block':

              _onBlockFramesController.add(data['x']);
              break;

            default:

              Settings.instance.logger.log(Level.INFO, 'Received data from ${url}: ');
              break;

          }},

            onDone: () async {

              print('Blockchain.info websocket is closed.');
              await connect();

            },

            onError: (error) {

              print('Blockchain.info websocket is closed due to an error: $error');

            });

        break;

    }

  }

  Stream<Map> get onBlockFrames => _onBlockFramesController.stream;

}