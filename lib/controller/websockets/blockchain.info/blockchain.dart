library websockets.blockchain.info;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/controller/websockets/channel.dart';

import 'requests.dart';

class BlockChainChannel extends Channel {

  BlockChainChannel() {

    pingRequest = Requests.ping;

    name = 'Blockchain';
    url  = 'wss://ws.blockchain.info/inv';

  }

  StreamController _onNewBlockController;

  Future connect() async {

    openDefaultStreams();
    _onNewBlockController = new StreamController();

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        onConnectController.add(webSocket.readyState);
        webSocket.add(Requests.subscribeToBlocks);

        webSocket.listen((event) {

          var data = JSON.decode(event);
          Settings.instance.logger.log(Level.FINE,'Raw data received from websocket: $data');

          switch(data['op']) {

            case 'pong':

              onPongController.add(data);
              break;

            case 'block':

              _onNewBlockController.add(data['x']);
              break;

            default:

              Settings.instance.logger.log(Level.INFO, 'Received data from ${url}: ');
              break;

          }},

          onDone: onDone, onError: onError);

        break;

    }

  }

  Future disconnect() async {

    await webSocket.close();

    onDisconnectController.add(webSocket.readyState);

    closeDefaultStreams();
    _onNewBlockController.close();


  }

  Stream<Map> get onNewBlock => _onNewBlockController.stream;

}