library dao;

import 'dart:async';
import 'dart:math';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Blockchain {

  DbCollection blocksCollection;

  Blockchain(Db db) {

    blocksCollection = db.collection('bitcoin_block');

  }

  Future<List<int>> findLastest(Map block) async {

    num secondsToMicroseconds(num value) => value * pow(10,6);

    List<Map> blocks = await blocksCollection.find(where.sortBy('time',descending: true).limit(1)).toList();

    return [blocks.length > 0 ? secondsToMicroseconds(blocks.first['time']) : 0, secondsToMicroseconds(block['time'])];

  }

  Future saveBlock(Map block) async {

    //AnsiPen redPen = new AnsiPen()..red(bold: true);
    //AnsiPen bluePen = new AnsiPen()..cyan(bold: true);

    /*int differenceInSeconds = new DateTime.fromMillisecondsSinceEpoch(block['time'] * 1000).difference(new DateTime.fromMillisecondsSinceEpoch(block['candles']['mts'] * 1000)).inSeconds; */

    /*Settings.instance.logger.log(Level.INFO,'Saving block ${bluePen(block['height'] as String)}, timestamp: ${redPen(block['time'] as String)} (${differenceInSeconds as String}) seconds of difference'); */

    Settings.instance.logger.log(Level.INFO,'Saving block ${block['height']}, timestamp: ${block['time']}');
    Settings.instance.logger.log(Level.INFO,'Candle data: ${block['candle']}');

    await blocksCollection.save(block);

  }

}