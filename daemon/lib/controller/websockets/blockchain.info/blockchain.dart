library websockets.blockchain.info;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/controller/websockets/channel.dart';

import 'requests.dart';

class BlockChainChannel extends Channel {

  BlockChainChannel({int secondsToTimeOut = 600}) : super(secondsToTimeOut) {

    name = 'Blockchain';
    url  = 'wss://ws.blockchain.info/inv';

  }

  StreamController _onNewBlockController = new StreamController.broadcast();

  Future connect() async {

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        onConnectController.add(webSocket.readyState);

        webSocket.add(Requests.ping);
        webSocket.add(Requests.subscribeToBlocks);

        // Ping the server once per minute
        new Future.delayed(new Duration(minutes: 5)).then((event) => webSocket.add(Requests.ping));

        webSocket.listen((event) {

          var data = json.decode(event);
          Settings.instance.logger.log(Level.FINE,'Raw data received from websocket: $data');

          switch(data['op']) {

            case 'pong':

            // Adds channel ID to the stream
              onHeartBeatController.add(data[0]);
              break;

            case 'block':

              _onNewBlockController.add(data['x']);
              break;

            default:

              Settings.instance.logger.log(Level.INFO, 'Received data from ${url}: ');
              break;

          }},

          onDone: onDone, onError: onError);

    }

  }

  Future disconnect() async {

    await webSocket.close();

  }

  Stream<Map> get onNewBlock => _onNewBlockController.stream;

}