import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/controller/websockets/bitfinex/bitfinex.dart';
import 'package:blockframe_daemon/controller/websockets/blockchain.info/blockchain.dart';
import 'package:blockframe_daemon/controller/websockets/channel.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';

class Loader {

  BlockChainChannel blockChainChannel = new BlockChainChannel();
  BitfinexChannel bitfinexChannel = new BitfinexChannel();

  void start() async {

    await Database.instance.open();

    await bitfinexChannel.connect();
    await blockChainChannel.connect();

    await listenToChannels();

  }

  void reconnect(events) async {

    Settings.instance.logger.log(Level.WARNING, events);

    if (bitfinexChannel.webSocket.readyState == WebSocket.OPEN) {

      await bitfinexChannel.disconnect();
      await blockChainChannel.disconnect();

      await new Future.delayed(new Duration(seconds: Channel.secondsToTimeOut));

      await bitfinexChannel.connect();
      await blockChainChannel.connect();

    }

  }

  Future listenToChannels() async {

    bitfinexChannel.onCandles.listen((List data) async {

      try {

        await Database.instance.bitfinex.saveCandles(data);

        // Resets the timeOut to reconnect each time we successfully save data
        bitfinexChannel.resetTimeOutToReconnect();

      }

      catch (exception,stackTrace) {

        Settings.instance.logger.log(Level.SEVERE,'An error has ocurred while trying to save candle data.');
        stderr.writeln(stackTrace);

      }

    });

    bitfinexChannel.onStall.listen((events) async => reconnect);
    blockChainChannel.onStall.listen((events) async => reconnect);

    blockChainChannel.onNewBlock.listen((Map block) async {

      try {

        // Resets the timeOut to reconnect each time we successfully save data
        blockChainChannel.resetTimeOutToReconnect();

        CustomCandle candle = await Database.instance.fetchCandleFromBlock(block);
        block['candle'] = candle.asMap;

        await Database.instance.blockchain.saveBlock(block);

      }

      catch (exception,stackTrace) {

        Settings.instance.logger.log(Level.SEVERE,'An error has ocurred while trying to save block data : $exception');
        stderr.writeln(stackTrace);

      }

    });

  }

}