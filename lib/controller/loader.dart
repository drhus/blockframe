import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/controller/websockets/channel.dart';
import 'package:blockframe_daemon/model/candle.dart';

class Loader {

  Duration reconnectionTime = new Duration(seconds: 30);

  var blockchain = new BlockChain();
  var bitfinex = new Bitfinex();

  Future start() async {

    await Database.instance.open();

    try {

      await _connect();

      await _listenToBitfinexEvents();
      await _listenToBlockChainInfoEvents();

    }

    on SocketException {

      Settings.instance.logger.log(Level.SEVERE,'An error ocurred while trying to access the servers. Please check your network connection');

    }

    catch (exception) {

      Settings.instance.logger.log(Level.SEVERE,exception);

    }

  }

  void _listenToBitfinexEvents() {

    bitfinex.onCandles.listen((candles) async {

      try {

        // Save updates
        if (candles.length == 6) {

          await Database.instance.bitfinex.saveCandles(candles);

        }

        else {

          // Save snapshot
          candles.forEach((candle) async {

            await Database.instance.bitfinex.saveCandles(candle);

          });

        }

      }

      catch (exception,stackTrace) {

        Settings.instance.logger.log(Level.SEVERE,'An error has ocurred while trying to save candle data.');
        stderr.writeln(stackTrace);

      }

    });

    bitfinex.onStall.listen((events) async {

      _reconnect(events);

    });

  }

  Future _listenToBlockChainInfoEvents() async {

    blockchain.onStall.listen((events) async {

      _reconnect(events);

    });

    blockchain.onNewBlock.listen((Map block) async {

      try {

        Candle candle = await Database.instance.fetchCandleFromNewBlock(block);

        await Database.instance.blockchain.save(block);
        await Database.instance.price.save(block['height'],candle.asMap);

      }

      catch (exception,stackTrace) {

        Settings.instance.logger.log(Level.SEVERE,'An error has ocurred while trying to save block data : $exception');
        stderr.writeln(stackTrace);

      }

    });

  }

  Future _connect() async {

    await bitfinex.connect();
    await blockchain.connect();

  }

  Future _disconnect() async {

    await bitfinex.disconnect();
    await blockchain.disconnect();

  }

  Future _reconnect(events) async {

    Settings.instance.logger.log(Level.WARNING, events);

    await _disconnect();
    sleep(Channel.timeout);
    await _connect();

    _listenToBitfinexEvents();
    _listenToBlockChainInfoEvents();

  }

}