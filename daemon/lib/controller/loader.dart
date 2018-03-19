import 'dart:async';

import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/controller/websockets/bitfinex/bitfinex.dart';
import 'package:blockframe_daemon/controller/websockets/blockchain.info/blockchain.dart';
import 'package:blockframe_daemon/model/candle.dart';

class Loader {

  BlockChainChannel blockChainChannel = new BlockChainChannel();
  BitfinexChannel bitfinexChannel = new BitfinexChannel();

  void start() async {

    await Database.instance.open();

    await bitfinexChannel.connect();
    await blockChainChannel.connect();

    await listenToChannels();

  }

  Future listenToChannels() async {

    bitfinexChannel.onCandles.listen((List data) async {

      await Database.instance.bitfinex.saveCandles(data);

    });

    blockChainChannel.onNewBlock.listen((Map block) async {

      Candle candle = await Database.instance.fetchCandleFromBlock(block);
      block['candle'] = candle.asMap;

      await Database.instance.blockchain.saveBlock(block);

    });

  }

}

