library dao;

import 'dart:async';

import 'package:blockframe_daemon/controller/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Blockchain {

  DbCollection blocksCollection;

  Blockchain(Db db) {

    blocksCollection = db.collection('blockchain');

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

  Future<bool> isEmpty() async {

    List blocks = await blocksCollection.find().toList();

    return blocks.length == 0;

  }

  Future save(Map block) async {

    var height = block['height'];

    Settings.instance.logger.log(Level.INFO,'Saving block ${Color.blue(height.toString())}');

    await blocksCollection.save(block);

  }

  Future<bool> exists(int height) async {

    int results = await blocksCollection.count(where.eq('height', height));

    return results == 1;

  }

}