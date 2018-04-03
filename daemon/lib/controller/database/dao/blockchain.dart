library dao;

import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Blockchain {

  DbCollection blocksCollection;

  Blockchain(Db db) {

    blocksCollection = db.collection('bitcoin_block');

  }

  Future<int> findLastestTimestamp() async {

    List data = (

        await blocksCollection

            .find(

              where

                  .sortBy('time',descending: true)
                  .limit(1)

            ).toList()

    );

    return data.isNotEmpty ? data.first['time'] : 0;

  }

  Future saveBlock(Map block) async {

    AnsiPen green = new AnsiPen()..green(bold: true);
    AnsiPen blue = new AnsiPen()..cyan(bold: true);
    AnsiPen red = new AnsiPen()..red(bold: true);

    var height = block['height'];
    var time = block['time'];
    var candle = block['candle'];

    Settings.instance.logger.log(Level.INFO,'Saving block ${blue(height.toString())}, timestamp: ${red(time.toString())}');
    Settings.instance.logger.log(Level.INFO,'Candle data: ${green(candle.toString())}');

    await blocksCollection.save(block);

  }

}