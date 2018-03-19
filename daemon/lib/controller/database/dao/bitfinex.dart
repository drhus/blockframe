import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/candle.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Bitfinex {

  DbCollection candlesCollection;

  Bitfinex(Db db) {

    candlesCollection = db.collection('bitfinex_candles');

  }

  Future<bool> candleExists(int timeStamp) async {

    List<Map> timestamps = await candlesCollection

        .find(where.eq('mts', timeStamp))
        .toList();

    return ! (timestamps.length == 0);

  }

  Future<List<Candle>> fetchCandles(int older, int newer) async {

    List<Map> pipeline = [

      /* Find the closest bitfinex entry that matches the bitcoin block timestamp */
      { r'$project' : { 'mts' : 1, 'open': 1, 'close': 1, 'high': 1, 'low': 1, 'volume': 1, 'diff' : { r'$abs' : { r'$subtract' : [newer, r'$mts'] }}}},
      { r'$sort' : { 'diff' : 1 }},
      /* Get all entries between the last block and and previous one (last and penultimate) */
      { r'$match' : { 'mts': { r'$gte': older, r'$lte': newer } } },
      { r'$sort' : { 'mts' : -1 }}

    ];

    var aggregateResults = (await candlesCollection.aggregateToStream(pipeline,cursorOptions: {}).toList());

    List<Candle> candles = aggregateResults.map((dynamic candle) {

      return new Candle(candle['mts'],candle['open'],candle['close'],candle['high'],candle['low'],candle['volume']);

    }).toList();

    candles.sort((Candle a,Candle b) => a.mts.compareTo(b.mts));

    return candles;

  }

  Future saveCandles(dynamic data) async {

    // First element is the channel ID
    for (var details in data.sublist(1,data.length)) {

      if (details is List) {

        Candle candle = new Candle.fromList(details);

        bool exists = await candleExists(candle.mts);

        if (! exists) {

          AnsiPen pen = new AnsiPen()..red(bold: true);
          Settings.instance.logger.log(Level.INFO,'Saving bitfinex transaction data on timestamp ${pen(candle.asMap.toString())}');
          candlesCollection.save(candle.asMap);

        }

        else {

          candlesCollection.update(where.exists('mts'), candle.asMap);

        }

      }

    }

  }

}