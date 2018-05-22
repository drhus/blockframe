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

    Settings.instance.logger.log(Level.FINE,'Saving bitfinex candle ${Color.green(candle.toString())}');
    priceCollection.insert({'block height' : blockHeight, 'candle' : candle});

  }

  Future<Map> fetchLatest() async {

    return (await fetchLastPrices(limit: 1)).toList().first;

  }

  Future<List<Map>> fetchLastPrices({int limit}) async {

    SelectorBuilder selectorBuilder =

    where

        .sortBy('height', descending: true);

    return await priceCollection.find(selectorBuilder.limit(limit ?? 0)).toList();

  }

}