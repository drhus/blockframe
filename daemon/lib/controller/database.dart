import 'dart:async';

import 'package:blockframe_daemon/controller/settings.dart';
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

  Future save(data) async {

    DbCollection collection = db.collection('bitcoin block');

    if (await collection.find({'hash': data['hash']}).isEmpty) {

      Settings.instance.logger.log(Level.INFO, 'Saving data from block: ${data["height"]}, hash: ${data["hash"]}');
      collection.save(data);

    }

  }

  Future close() async {

    await db.close();

  }

}