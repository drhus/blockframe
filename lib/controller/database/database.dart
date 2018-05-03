import 'dart:async';
import 'dart:math';

import 'package:blockframe_daemon/controller/database/dao/dao.dart' as dao;
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Database {

  static Database _instance = new Database._private();
  static Database get instance => _instance;

  Db _db;

  dao.Bitfinex bitfinex;
  dao.Blockchain blockchain;

  Database._private() {

    _db = new Db('mongodb://localhost:27017/blockframe');

    bitfinex = new dao.Bitfinex(_db);
    blockchain = new dao.Blockchain(_db);

  }

  /// Weighted candle
  Future<CustomCandle> fetchCandleFromBlock(Map block) async {

    List<CustomCandle> candles = await fetchCandlesByBlockHeight(block['height']);

    return candles.isNotEmpty ? CustomCandle.adjustValues(candles) : null;

  }

  Future<List<CustomCandle>> fetchCandlesByBlockHeight(int height) async {

    int newer;

    bool exists = await blockchain.exists(height);
    if (! exists) throw new RangeError("Block $height doesn't exists");

    bool hasNext = await blockchain.hasNext(height);

    Map block = await blockchain.fetchBlock(height);
    int older = block['time'] * pow(10,6);

    if (hasNext) {

      int next = await blockchain.next(height);
      newer = (await blockchain.fetchBlock(next))['time'] * pow(10,6);

    }

    else {

      newer = (await blockchain.findLastestTimestamp() * pow(10,6));

    }

    return await bitfinex.fetchCandles(older, newer);

  }

  Future<CustomCandle> fetchCandleFromNewBlock(Map block) async {

    int older = await blockchain.isEmpty()

      ? 0
      : (await blockchain.fetchLatestBlock())['price']['luts'];

    int newer = (await bitfinex.fetchClosestCandleTimestamp(block['time'] * pow(10,6)));

    Settings.instance.logger.log(Level.FINE,'Previous block timestamp: ${older} µs');
    Settings.instance.logger.log(Level.FINE,'Current block timestamp: ${newer} µs');

    List candles = await bitfinex.fetchCandles(older,newer);

    return candles.isNotEmpty ? CustomCandle.adjustValues(candles) : null;

  }

  Future open() async {

    await _db.open();

  }

}