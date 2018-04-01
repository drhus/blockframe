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

    try {

      await _connect();

      await _listenToBitfinexEvents();
      await _listenToBlockChainInfoEvents();

    }

    on SocketException {

      Settings.instance.logger.log(Level.SEVERE,'An error ocurred while trying to access the servers. Please check your network connection');
      Settings.instance.logger.log(Level.SEVERE,'Exiting ...');

    }

    catch (exception) {

      Settings.instance.logger.log(Level.SEVERE,exception);
      exit(-1);

    }

  }

  void _listenToBitfinexEvents() {

    bitfinexChannel.onCandles.listen((List data) async {

      try {

        bitfinexChannel.resetTimeOutToReconnect();
        await Database.instance.bitfinex.saveCandles(data);

      }

      catch (exception,stackTrace) {

        Settings.instance.logger.log(Level.SEVERE,'An error has ocurred while trying to save candle data.');
        stderr.writeln(stackTrace);

      }

    });

    bitfinexChannel.onStall.listen((events) async {

      _reconnect(events);

    });

  }

  Future _listenToBlockChainInfoEvents() async {

    blockChainChannel.onStall.listen((events) async {

      _reconnect(events);

    });

    blockChainChannel.onNewBlock.listen((Map block) async {

      blockChainChannel.resetTimeOutToReconnect();

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

  Future _connect() async {

    await bitfinexChannel.connect();
    await blockChainChannel.connect();

  }

  Future _disconnect() async {

    await bitfinexChannel.disconnect();
    await blockChainChannel.disconnect();

  }

  void _reconnect(events) async {

    Settings.instance.logger.log(Level.WARNING, events);

    await _disconnect();
    sleep(Channel.timeout);
    await _connect();

  }

}