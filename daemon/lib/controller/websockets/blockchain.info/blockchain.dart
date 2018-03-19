library websockets.blockchain.info;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/channel.dart';

import 'requests.dart';

class BlockChainChannel extends Channel {

  BlockChainChannel() {

    name = 'Blockchain';
    url  = 'wss://ws.blockchain.info/inv';

  }

  StreamController _onNewBlockController = new StreamController.broadcast();

  Future connect() async {

    webSocket = await WebSocket.connect(url);

    switch(webSocket.readyState) {

      case WebSocket.OPEN:

        onConnectController.add(webSocket.readyState);

        //webSocket.add(Requests.ping);
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