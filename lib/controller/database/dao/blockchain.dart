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

                  .sortBy('height',descending: true)
                  .limit(1)

            ).toList()

    );

    return data.isNotEmpty ? data.first['time'] : 0;

  }

  Future<List<Map>> fetchAllBlocks(List<int> blocks) async {

    List<Map<dynamic,dynamic>> list = await blocksCollection

        .find(where

        .gte('height', blocks.first)
        .lte('height', blocks.last)

    ).toList();

    list.sort((Map a,Map b) => (a['height'] as int).compareTo(b['height'] as int));

    return list;

  }

  Future<List<Map>> fetchLastBlocks({blocks: int}) async {

    List<Map<dynamic,dynamic>> list = await blocksCollection.find(where.sortBy('height',descending: true).limit(blocks)).toList();

    return list;

  }

  Future save(Map block) async {

    //AnsiPen green = new AnsiPen()..green(bold: true);
    AnsiPen blue = new AnsiPen()..cyan(bold: true);
    AnsiPen red = new AnsiPen()..red(bold: true);

    var height = block['height'];
    var time = block['time'];

    Settings.instance.logger.log(Level.INFO,'Saving block ${blue(height.toString())}, timestamp: ${red(time.toString())}');

    await blocksCollection.save(block);

  }

}