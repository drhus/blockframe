import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:test/test.dart';

HttpClient client = new HttpClient();

const int height = 514999;
Map block = {};

Future<Map> fetchBlock() async {

  HttpClientRequest request = await client.getUrl(Uri.parse('https://blockchain.info/pt/block-height/$height?format=json'));
  HttpClientResponse response = await request.close();

  Map block = json.decode(await response.transform(utf8.decoder).join());

  return block['blocks'].first;

}

Future main() async {

  await Database.instance.open();

  block = await fetchBlock();

  group('blockchain.info',() {

    test('find latest timestamp', () async {

        var latest = await Database.instance.blockchain.findLastestTimestamp();
        expect(latest is int,true);

    });

  });

  group('Bitfinex',() {

    test('fetch candle data', () async {

      int older = await Database.instance.blockchain.findLastestTimestamp();
      int newer = block['time'];

      var candles = await Database.instance.bitfinex.fetchCandles(older * pow(10,6), newer * pow(10,6));
      expect(candles.length >= 0,true);

    });

  });

}
