import 'dart:async';
import 'dart:math';

import 'package:blockframe_daemon/controller/database/dao/bitcoin.dart' as bitcoin;
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/candle.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Database {

  static Database _instance = new Database._private();
  static Database get instance => _instance;

  Db _db;

  bitcoin.Bitfinex bitfinex;
  bitcoin.Blockchain blockchain;
  bitcoin.Price price;

  Database._private() {

    _db = new Db('mongodb://localhost:27017/bitcoin');

    bitfinex = new bitcoin.Bitfinex(_db);
    blockchain = new bitcoin.Blockchain(_db);
    price = new bitcoin.Price(_db);

  }

  /// Weighted candle
  Future<Candle> fetchCandleFromBlock(Map block) async {

    List<Candle> candles = await fetchCandlesByBlockHeight(block['height']);

    return candles.isNotEmpty ? Candle.adjustValues(candles) : null;

  }

  Future<List<Candle>> fetchCandlesByBlockHeight(int height) async {

    int newer;

    bool exists = await blockchain.exists(height);
    if (! exists) throw new RangeError("Block $height doesn't exists");

    bool hasNext = await blockchain.hasNext(height);

    Map block = await blockchain.fetchBlock(height);
    int older = block['time'] * pow(10,6);

    if (hasNext) {

      int next = await blockchain.next(height);
      newer = (await blockchain.fetchBlock(next))['time'] * 1000;

    }

    else {

      newer = (await blockchain.findLastestTimestamp() * 1000);

    }

    return await bitfinex.fetchCandles(older, newer);

  }

  Future<Candle> fetchCandleFromNewBlock(Map block) async {

    int older = await blockchain.isEmpty()

      ? 0
      : (await price.fetchLatest()).mts;

    int newer = (await bitfinex.fetchClosestCandleByTimestamp(block['time']));

    Settings.instance.logger.log(Level.FINE,'Previous block timestamp: ${older} µs');
    Settings.instance.logger.log(Level.FINE,'Current block timestamp: ${newer} µs');

    List candles = await bitfinex.fetchCandles(older,newer);

    if (candles == null) throw new NullThrownError();

    return Candle.adjustValues(candles);

  }

  Future open() async {

    await _db.open();

  }

}