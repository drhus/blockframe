import 'dart:async';
import 'dart:math';

import 'package:blockframe_daemon/controller/database/dao/dao.dart' as dao;
import 'package:blockframe_daemon/model/custom_candle.dart';
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
    int older;

    bool exists = await blockchain.exists(height);
    bool hasNext = await blockchain.hasNext(height);

    if (exists && hasNext) {

      int next = await blockchain.next(height);
      newer = (await blockchain.fetchBlock(next))['time'] * pow(10,6);

    }

    else if (exists && ! hasNext ){

      newer = (await blockchain.findLastestTimestamp() * pow(10,6));

    }

    older = (await Database.instance.blockchain.fetchBlock(height))['time'] * pow(10,6);

    return await bitfinex.fetchCandles(older, newer);

  }

  Future open() async {

    await _db.open();

  }

}