import 'dart:async';
import 'dart:core';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/model.dart' as model;
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Price {

  DbCollection priceCollection;

  Price(Db db) {

    priceCollection = db.collection('price');

  }

  Future save(int blockHeight,Map candle) async {

    Map price = {

      'block height' : blockHeight,

      'mts' : candle['mts'],
      'open' : candle['open'],
      'close' : candle['close'],
      'high' : candle['high'],
      'low' : candle['low'],
      'volume' : candle['volume']

    };

    Settings.instance.logger.log(Level.INFO,'Saving bitcoin price ${Color.green(price.toString())}');
    priceCollection.insert(price);

  }

  Future<model.Price> fetchLatest() async {

    model.Price latest = (await fetchLastPrices(limit: 1)).first;

    return latest;

  }

  Future<List<model.Price>> fetchLastPrices({int limit}) async {

    SelectorBuilder selectorBuilder =

    where

        .sortBy('block height', descending: true);

    return await priceCollection.find(selectorBuilder.limit(limit ?? 0)).map((Map data) {

      return new model.Price(data['block height'], data['block time'], data['mts'], data['open'], data['close'], data['high'], data['low'], data['volume']);

    }).toList();

  }

}