import 'dart:async';
import 'dart:core';

import 'package:blockframe_daemon/controller/settings.dart';
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

  Future<Map> fetchLatest() async {

    Map latest = (await fetchLastPrices(limit: 1)).toList().first;

    return latest;

  }

  Future<List<Map>> fetchLastPrices({int limit}) async {

    SelectorBuilder selectorBuilder =

    where

        .sortBy('block height', descending: true);

    return await priceCollection.find(selectorBuilder.limit(limit ?? 0)).toList();

  }

}