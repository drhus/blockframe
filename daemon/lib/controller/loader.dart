import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/controller/websockets/bitfinex/bitfinex.dart';
import 'package:blockframe_daemon/controller/websockets/blockchain.info/blockchain.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';

class Loader {

  BlockChainChannel blockChainChannel = new BlockChainChannel(secondsToTimeOut: 600);
  BitfinexChannel bitfinexChannel = new BitfinexChannel(secondsToTimeOut: 30);

  void start() async {

    await Database.instance.open();

    await bitfinexChannel.connect();
    await blockChainChannel.connect();

    await listenToChannels();

  }

  Future listenToChannels() async {

    bitfinexChannel.onCandles.listen((List data) async {

      try {

        await Database.instance.bitfinex.saveCandles(data);

      }

      catch (exception,stackTrace) {

        Settings.instance.logger.log(Level.SEVERE,'An error has ocurred while trying to save candle data.');
        stderr.writeln(stackTrace);

      }

    });

    blockChainChannel.onNewBlock.listen((Map block) async {

      try {

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