import 'dart:async';
import 'dart:core';

import 'dart:math';
import 'package:ansicolor/ansicolor.dart';
import 'package:blockframe_daemon/controller/database/dao/blockchain.dart';
import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Bitfinex {

  DbCollection candlesCollection;

  Bitfinex(Db db) {

    candlesCollection = db.collection('bitfinex_candles');

  }

  /// [blockTime] is in µ seconds
  Future<int> fetchClosestCandleTimestamp(int blockTime) async {

    List<Map> pipeline = [

      {

        r'$project': {

          'luts': 1,
          'diff': { r'$abs': { r'$subtract': [blockTime, r'$luts']}},

        }
      },

      // Get the closest value
      { r'$sort': { 'diff': 1}},
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
          'candle.mts': 1,
          'candle.open': 1,
          'candle.close': 1,
          'candle.high': 1,
          'candle.low': 1,
          'candle.volume': 1

        }
      },

      /* Get all entries between the last block and and previous one (last and penultimate) */
      { r'$match': { 'luts': { r'$gte': older, r'$lte': newer}}},
      { r'$sort': { 'luts': 1}}

    ];

    List aggregateResults = (await candlesCollection.aggregateToStream(pipeline,cursorOptions: {}).toList());

    List<CustomCandle> results = aggregateResults.map((dynamic candle) {

      return new CustomCandle(

          candle['luts'],

          candle['candle']['mts'],
          candle['candle']['open'],
          candle['candle']['close'],
          candle['candle']['high'],
          candle['candle']['low'],
          candle['candle']['volume']);

    }).toList();

    return results;

  }

  Future saveCandles(List data) async {

    AnsiPen greenPen = new AnsiPen()..green(bold: true);
    /*AnsiPen bluePen = new AnsiPen()..blue(bold: true);
    AnsiPen redPen = new AnsiPen()..red(bold: true);*/

    CustomCandle candle = new CustomCandle.fromList(data);

    Settings.instance.logger.log(Level.FINE,'Saving bitfinex candle ${greenPen(candle.asMap.toString())}');
    candlesCollection.insert(candle.asMap);

  }

}