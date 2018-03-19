import 'dart:async';

import 'package:blockframe_daemon/controller/database/dao/dao.dart' as dao;
import 'package:blockframe_daemon/model/candle.dart';
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

  Future<Candle> fetchCandleFromBlock(Map block) async {

    List<int> range = await blockchain.findLastest(block);
    List<Candle> candles = await bitfinex.fetchCandles(range.first,range.last);

    return Candle.adjustValues(candles);

  }

  Future open() {

    _db.open();

  }

}