import 'dart:async';
import 'dart:core';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Bitfinex {

  DbCollection candlesCollection;

  Bitfinex(Db db) {

    candlesCollection = db.collection('candle data');

  }

  /// [blockTime] is in seconds
  Future<int> fetchClosestCandleByTimestamp(int blockTime) async {

    List<Map> pipeline = [

      {

        r'$project': {

          'luts': 1,
          'diff': { r'$abs' : { r'$subtract' : [blockTime * 1000 * 1000, r'$luts']}},

        }

      },

      // Get the closest value
      { r'$sort'  : { 'diff': 1 }},
      { r'$limit' : 1 }

    ];

    List aggregateResults = (await candlesCollection.aggregateToStream(pipeline,cursorOptions: {}).toList());

    Settings.instance.logger.log(Level.FINE,'Fetching closest candle timestamp that corresponds to block time $blockTime µs <--> ${aggregateResults.first['luts']} µs');

    return aggregateResults.first['luts'];

  }

  /// For correct operation [older] and [newer] should be in µ seconds
  Future<List<CustomCandle>> fetchCandles(int older, int newer) async {

    List<Map> pipeline = [

      {

        r'$project': {

          'luts': 1,
          'mts': 1,
          'open': 1,
          'close': 1,
          'high': 1,
          'low': 1,
          'volume': 1

        }
      },

      /* Get all entries between the last block and and previous one (last and penultimate) */
      { r'$match': { 'luts': { r'$gt': older, r'$lt': newer}}},
      { r'$sort': { 'luts': 1}}

    ];

    List aggregateResults = (await candlesCollection.aggregateToStream(pipeline,cursorOptions: {}).toList());

    List<CustomCandle> results = aggregateResults.map((dynamic candle) {

      return new CustomCandle.fromMap(candle);


    }).toList();

    return results;

  }

  Future saveCandles(List data) async {

    CustomCandle candle = new CustomCandle.fromList(data);

    Settings.instance.logger.log(Level.FINE,'Saving bitfinex candle ${Color.green(candle.asMap.toString())}');
    candlesCollection.insert(candle.asMap);

  }

}