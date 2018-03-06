import 'dart:async';

import 'package:blockframe_server/controller/settings.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Database {

  static Database _instance = new Database._private();
  static Database get instance => _instance;

  Db db;

  Database._private() {

    db = new Db("mongodb://localhost:27017/blockframe");

  }

  Future open() async {

    await db.open();

  }

  Future<List<Map>> fetchLastBlock({blocks: int}) async {

    return await db.collection('bitcoin block').find({}).take(blocks).toList();

  }

  Future save(data) async {

    DbCollection collection = db.collection('bitcoin block');
    Settings.instance.logger.log(Level.INFO, 'Saving data: ${data}');

    collection.find({'hash': data['hash']}).isEmpty.then((success) {

      collection.save(data);

    });

  }

  Future close() async {

    await db.close();

  }

}