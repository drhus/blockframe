import 'dart:async';

import 'package:blockframe_server/controller/settings.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Database {

  static Database _instance = new Database._private();
  Db db;

  Database._private() {

    db = new Db("mongodb://localhost:27017/blockframe");

  }

  Future open() async {

    await db.open();

  }

  Future<List<Map>> fetchBlocks(List<int> blocks) async {

    List<Map<dynamic,dynamic>> list = await db.collection('bitcoin block')

      .find(where

        .gte('height', blocks.first)
        .lte('height', blocks.last)

    ).toList();

    list.sort((Map a,Map b) => (a['height'] as int).compareTo(b['height'] as int));

    return list;

  }

  Future<List<Map>> fetchLastBlocks({blocks: int}) async {

    List<Map<dynamic,dynamic>> list = await db.collection('bitcoin_block').find(where.sortBy('time').limit(blocks)).toList();

    list.sort((Map a,Map b) => (a['height'] as int).compareTo(b['height'] as int));

    return list;

  }

  Future save(Map data) async {

    DbCollection collection = db.collection('bitcoin_block');
    Settings.instance.logger.log(Level.INFO, 'Saving data: ${data}');

    collection.find({'hash': data['hash']}).isEmpty.then((success) {

      collection.save(data);

    });

  }

  Future close() async {

    await db.close();

  }

  static Database get instance => _instance;

}