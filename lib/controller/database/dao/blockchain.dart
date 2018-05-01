library dao;

import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:blockframe_daemon/controller/settings.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';
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

                  .sortBy('height',descending: true)
                  .limit(1)

            ).toList()

    );

    return data.isNotEmpty ? data.first['time'] : 0;

  }

  Future<bool> hasNext(int height) async {

    List results = (await blocksCollection.find(where.gte('height', height).limit(2)).toList());

    return (results.length == 2);

  }

  Future<int> next(int height) async {

    List results = (await blocksCollection

        .find(where.gte('height', height)
        .sortBy('height',descending: false)
        .limit(2))
        .toList()

    );

    return await results.last['height'];

  }

  Future<Map> fetchBlock(int height) async {

    SelectorBuilder selectorBuilder =

    where

        .eq('height', height)
        .sortBy('height', descending: true);

    return (await blocksCollection.find(selectorBuilder.limit(1)).toList()).first;

  }

  Future <List<Map>> fetchBlocks(int first, int last, { int limit }) async {

    SelectorBuilder selectorBuilder =

    where

        .gte('height', first)
        .lte('height', last)
        .sortBy('height', descending: true);

    return await blocksCollection.find(selectorBuilder.limit(limit ?? 0)).toList();


  }

  Future<Map> fetchLatestBlock() async {

    return (await fetchLastBlocks(limit: 1)).toList().first;

  }

  Future<List<Map>> fetchLastBlocks({int limit}) async {

    SelectorBuilder selectorBuilder =

        where

            .sortBy('height', descending: true);

    return await blocksCollection.find(selectorBuilder.limit(limit ?? 0)).toList();

  }

  Future save(Map block) async {

    AnsiPen green = new AnsiPen()..green(bold: true);
    AnsiPen blue = new AnsiPen()..cyan(bold: true);
    AnsiPen red = new AnsiPen()..red(bold: true);

    var height = block['height'];
    var time = block['time'];

    Settings.instance.logger.log(Level.INFO,'Saving block ${blue(height.toString())}. Candle: ${green(block['price'].toString())}');

    await blocksCollection.save(block);

  }

  Future<bool> exists(int height) async {

    int results = await blocksCollection.count(where.eq('height', height));

    return results == 1;

  }

}